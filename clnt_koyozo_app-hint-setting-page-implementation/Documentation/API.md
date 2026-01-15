# API Documentation

## Overview
This document describes the API endpoints used by the Koyozo iOS app.

## Authentication Endpoints

### POST /auth/login
Login with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "access_token": "token",
  "refresh_token": "refresh_token",
  "expires_in": 3600,
  "user": {
    "id": "user_id",
    "name": "User Name",
    "email": "user@example.com"
  }
}
```

## Game Endpoints

### GET /games
Fetch list of games.

**Response:**
```json
{
  "games": [
    {
      "id": "543186831",
      "title": "8 Ball Pool",
      "thumbnail_url": "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/17/c7/c0/17c7c065-f17c-f178-07eb-a2ee3fbe6121/AppIcon-0-0-1x_U007emarketing-0-8-0-85-220.png/512x512bb.jpg",
      "background_url": "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/43/12/8d/43128dbd-14d3-70ed-681d-797434e47858/1ed3fb00-9f3a-403f-bf93-09ef2b4d2a2e_8BP-SCR-Screenshots_iPadPro_001.jpg/552x414bb.jpg",
      "description": "Play with friends! Play with Legends. Play the hit Miniclip 8 Ball Pool game on your mobile and become the best!",
      "launch_url": "https://apps.apple.com/us/app/8-ball-pool/id543186831?uo=4",
      "app_store_id": "543186831"
    }
  ],
  "total": 100,
  "page": 1,
  "page_size": 20
}
```

**Field Descriptions:**

**Required Fields:**
- `id` (string, required): Unique game identifier
- `title` (string, required): Game title/name
- `thumbnail_url` (string, required): Smaller square/portrait image (e.g., 400x600) used for game icons in lists and grids
- `launch_url` (string, required): URL scheme or App Store link to launch the game
- `app_store_id` (string, required): App Store ID for fallback if game is not installed

**Optional Fields:**
- `background_url` (string, optional): Larger landscape image (e.g., 1920x1080) used for full-screen background when game is selected. Falls back to `thumbnail_url` if not provided
- `description` (string, optional): Game description

**Response Metadata:**
- `total` (integer): Total number of games available
- `page` (integer): Current page number
- `page_size` (integer): Number of games per page
