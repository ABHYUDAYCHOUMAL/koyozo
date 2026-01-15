//
//  AuthRemoteDataSource.swift
import Foundation

protocol AuthRemoteDataSourceProtocol {
    func login(email: String, password: String) async throws -> AuthToken
    func checkEmailExists(email: String) async throws -> LoginCheckResult
    func signup(name: String, email: String, password: String) async throws -> AuthToken
    func register(email: String, password: String, username: String, DOB: String, gender: String) async throws -> AuthToken
    func signInWithGoogle(email: String, username: String?) async throws -> AuthToken
    func sendOTP(email: String, type: Int) async throws -> Void
    func verifyOTP(email: String, otp: String, type: Int) async throws -> Void
    func logout() async throws
    func resetPassword(email: String, newPassword: String) async throws -> Void
    func setPassword(password: String) async throws -> Void
}

enum LoginCheckResult {
    case emailExists
    case emailNotFound
    case error(Error)
}

struct SocialLoginEndpoint: APIEndpoint {
    let path: String = "/auth/login-or-register"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    let body: Data?
    let queryParameters: [String: String]? = nil
    
    init(request: SocialLoginRequestDTO) {
        self.body = try? JSONEncoder().encode(request)
    }
}

struct LoginEndpoint: APIEndpoint {
    let path: String = "/auth/login"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    let body: Data?
    let queryParameters: [String: String]? = nil
    
    init(request: LoginRequestDTO) {
        self.body = try? JSONEncoder().encode(request)
    }
}

struct SendOTPEndpoint: APIEndpoint {
    let path: String = "/auth/send-otp"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    let body: Data?
    let queryParameters: [String: String]? = nil
    
    init(request: SendOTPRequestDTO) {
        self.body = try? JSONEncoder().encode(request)
    }
}

struct VerifyOTPEndpoint: APIEndpoint {
    let path: String = "/auth/verify-otp"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    let body: Data?
    let queryParameters: [String: String]? = nil
    
    init(request: VerifyOTPRequestDTO) {
        self.body = try? JSONEncoder().encode(request)
    }
}

struct RegisterEndpoint: APIEndpoint {
    let path: String = "/auth/register"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    let body: Data?
    let queryParameters: [String: String]? = nil
    
    init(request: RegisterRequestDTO) {
        self.body = try? JSONEncoder().encode(request)
    }
}

struct ResetPasswordEndpoint: APIEndpoint {
    let path: String = "/auth/reset-password"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    let body: Data?
    let queryParameters: [String: String]? = nil
    
    init(request: ResetPasswordRequestDTO) {
        self.body = try? JSONEncoder().encode(request)
    }
}

struct CheckEmailEndpoint: APIEndpoint {
    let path: String = "/check-email"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    let body: Data?
    let queryParameters: [String: String]? = nil
    
    init(request: CheckEmailRequestDTO) {
        self.body = try? JSONEncoder().encode(request)
    }
}

final class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? AppDependencies.shared.apiClient
    }
    
    func login(email: String, password: String) async throws -> AuthToken {
        let requestDTO = LoginRequestDTO(email: email, password: password)
        let endpoint = LoginEndpoint(request: requestDTO)
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            let response = try decoder.decode(FirebaseResponseDTO<SocialLoginResponseDataDTO>.self, from: data)
            
            guard !response.hasError else {
                throw AppError.authenticationFailed
            }
            
            return AuthToken(
                accessToken: response.data.token,
                refreshToken: nil,
                expiresIn: 3600
            )
        } catch let error as NetworkError {
            if case .notFound = error {
                throw AppError.authenticationFailed
            }
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func checkEmailExists(email: String) async throws -> LoginCheckResult {
        let requestDTO = CheckEmailRequestDTO(email: email)
        let endpoint = CheckEmailEndpoint(request: requestDTO)
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            let response = try decoder.decode(FirebaseResponseDTO<CheckEmailResponseDataDTO>.self, from: data)
            
            guard !response.hasError else {
                // If there's an error, treat it as email not found or return error
                if response.status == 400 || response.status == 404 {
                    return .emailNotFound
                }
                return .error(AppError.unknown)
            }
            
            // Check the exists field in the response data
            if response.data.exists {
                return .emailExists
            } else {
                return .emailNotFound
            }
        } catch let error as NetworkError {
            // Handle network errors
            if case .notFound = error {
                return .emailNotFound
            }
            return .error(error)
        } catch {
            return .error(error)
        }
    }
    
    func signup(name: String, email: String, password: String) async throws -> AuthToken {
        // Signup is handled by register endpoint after OTP verification
        // This method is kept for compatibility but should not be used directly
        throw AppError.unknown
    }
    
    func register(email: String, password: String, username: String, DOB: String, gender: String) async throws -> AuthToken {
        let requestDTO = RegisterRequestDTO(
            email: email,
            password: password,
            username: username,
            DOB: DOB,
            gender: gender
        )
        
        let endpoint = RegisterEndpoint(request: requestDTO)
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            // Register returns a message response, not a token
            let response = try decoder.decode(FirebaseResponseDTO<OTPResponseDataDTO>.self, from: data)
            
            guard !response.hasError else {
                throw AppError.unknown
            }
            
            // After successful registration, automatically login the user
            return try await login(email: email, password: password)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func sendOTP(email: String, type: Int) async throws -> Void {
        let requestDTO = SendOTPRequestDTO(email: email, type: type)
        let endpoint = SendOTPEndpoint(request: requestDTO)
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            let response = try decoder.decode(FirebaseResponseDTO<OTPResponseDataDTO>.self, from: data)
            
            guard !response.hasError else {
                throw AppError.unknown
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func verifyOTP(email: String, otp: String, type: Int) async throws -> Void {
        let requestDTO = VerifyOTPRequestDTO(email: email, otp: otp, type: type)
        let endpoint = VerifyOTPEndpoint(request: requestDTO)
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            let response = try decoder.decode(FirebaseResponseDTO<OTPResponseDataDTO>.self, from: data)
            
            guard !response.hasError else {
                throw AppError.unknown
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func signInWithGoogle(email: String, username: String?) async throws -> AuthToken {
        let requestDTO = SocialLoginRequestDTO(
            email: email,
            username: username,
            type: "google",
            gender: "male",
            DOB: "01-01-2000"
        )
        
        let endpoint = SocialLoginEndpoint(request: requestDTO)
        
        do {
            // Decode the raw response data manually to handle Firebase response format
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            // Don't use snake_case conversion for Firebase response
            let response = try decoder.decode(FirebaseResponseDTO<SocialLoginResponseDataDTO>.self, from: data)
            
            guard !response.hasError else {
                throw AppError.unknown
            }
            
            // Convert Firebase response to AuthToken
            return AuthToken(
                accessToken: response.data.token,
                refreshToken: nil,
                expiresIn: 3600 // Default 1 hour
            )
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func logout() async throws {
        // Implement API call for logout
    }
    
    
    func resetPassword(email: String, newPassword: String) async throws -> Void {
        let requestDTO = ResetPasswordRequestDTO(email: email, newPassword: newPassword)
        let endpoint = ResetPasswordEndpoint(request: requestDTO)
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            let response = try decoder.decode(FirebaseResponseDTO<OTPResponseDataDTO>.self, from: data)
            
            guard !response.hasError else {
                throw AppError.unknown
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func setPassword(password: String) async throws -> Void {
        // setPassword is not a separate endpoint
        // It's handled by resetPassword or register
        throw AppError.unknown
    }
}

