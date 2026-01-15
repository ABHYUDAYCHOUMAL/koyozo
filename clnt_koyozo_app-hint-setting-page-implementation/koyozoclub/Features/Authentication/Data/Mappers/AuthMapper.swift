//
//  AuthMapper.swift
import Foundation

struct AuthMapper {
    static func toDomain(from dto: AuthResponseDTO) -> (token: AuthToken, user: User) {
        let token = AuthToken(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: TimeInterval(dto.expiresIn)
        )
        
        let user = User(
            id: dto.user.id,
            name: dto.user.name,
            email: dto.user.email,
            profileImageURL: dto.user.profileImageURL,
            createdAt: ISO8601DateFormatter().date(from: dto.user.createdAt) ?? Date()
        )
        
        return (token, user)
    }
}

