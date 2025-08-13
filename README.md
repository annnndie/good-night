# Good Night API

A Ruby on Rails API application for tracking sleep records and social following functionality. Users can record multiple sleep sessions per day (including naps), view their sleep history, and follow friends to see their sleep patterns.

## 🎯 Requirements Implementation

This application addresses the three core requirements specified:

### 1. Clock In/Out Operations
**Requirement**: Clock In operation, return all clocked-in times ordered by created time
- **Implementation**: `POST /api/v1/sleep_records` for clock-in, `PATCH /api/v1/sleep_records/:id` for clock-out
- **Returns**: All user's sleep records ordered by `created_at DESC`

### 2. Follow/Unfollow System
**Requirement**: Users can follow and unfollow other users
- **Implementation**: `POST /api/v1/users/follow` and `POST /api/v1/users/unfollow`
- **Business Logic**: Prevents duplicate follows and includes validation

### 3. Following Users' Sleep Records
**Requirement**: See sleep records of all following users from previous week, sorted by duration
- **Implementation**: `GET /api/v1/sleep_records/following`
- **Response Format**: Mixed records from different users (as specified in example)
- **Sorting**: By sleep duration DESC (longest to shortest)
- **Pagination**: Supports pagination with configurable page size

## 🛠 Tech Stack

- **Ruby**: 3.4.5
- **Rails**: 8.0.2
- **Database**: MySQL 8.0
- **Testing**: RSpec + FactoryBot
- **Code Style**: RuboCop Rails Omakase

## 🚀 Development Setup

### Prerequisites
- Docker & Docker Compose

### Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd good-night
   ```

2. **Start development environment**
   ```bash
   docker-compose up -d
   ```

3. **Setup database**
   ```bash
   docker-compose exec app rails db:create db:migrate db:seed
   ```

4. **Access the application**
   - API: http://localhost:3001
   - Database: localhost:3306 (username: root, password: password)

## 📚 API Documentation

### Authentication
All API requests require a `X-User-ID` header with the user's ID.

### Endpoints

#### Sleep Records

**Create Sleep Record (Clock In)**
```http
POST /api/v1/sleep_records
Content-Type: application/json
X-User-ID: 1

{
  "sleep_record": {
    "sleep_at": "2025-01-15T23:30:00Z"
  }
}
```

**Update Sleep Record (Clock Out)**
```http
PATCH /api/v1/sleep_records/:id
Content-Type: application/json
X-User-ID: 1

{
  "sleep_record": {
    "wake_at": "2025-01-16T07:30:00Z"
  }
}
```

**Get Personal Sleep Records**
```http
GET /api/v1/sleep_records?page=1&limit=10
X-User-ID: 1
```
*Parameters:*
- `page`: Page number (default: 1)
- `limit`: Items per page (optional, default: 10, max: 100)

**Get Following Users' Sleep Records**
```http
GET /api/v1/sleep_records/following?page=1&limit=10
X-User-ID: 1
```
*Parameters:*
- `page`: Page number (default: 1)
- `limit`: Items per page (optional, default: 10, max: 100)

#### User Following

**Follow User**
```http
POST /api/v1/users/follow
Content-Type: application/json
X-User-ID: 1

{
  "user": {
    "id": 2
  }
}
```

**Unfollow User**
```http
POST /api/v1/users/unfollow
Content-Type: application/json
X-User-ID: 1

{
  "user": {
    "id": 2
  }
}
```


## 🗄 Database Schema

### Users
- `id` (Primary Key)
- `name` (String)
- `created_at`, `updated_at`

### Sleep Records
- `id` (Primary Key)
- `user_id` (Foreign Key)
- `sleep_at` (DateTime, required)
- `wake_at` (DateTime, optional)
- `duration` (Integer, calculated in seconds)
- `created_at`, `updated_at`

### Follows
- `id` (Primary Key)
- `follower_id` (Foreign Key to Users)
- `followed_id` (Foreign Key to Users)
- `created_at`, `updated_at`

### Database Indexes
- **follows**: Unique composite index on `[follower_id, followed_id]`
- **sleep_records**: Composite index on `[user_id, created_at]` for following queries optimization

## 📝 Business Rules

### Sleep Records
- `sleep_at` is required when creating a record
- `wake_at` cannot be cleared once set
- `wake_at` must be after `sleep_at`
- `duration` is automatically calculated when both times are present
- Duration is stored in seconds

### Following System
- Users cannot follow themselves
- Duplicate follow relationships are prevented
- Following relationships are used to filter sleep records visibility

## 🤝 Contributing

1. Follow the existing code style (RuboCop Rails Omakase)
2. Write tests for new features
3. Use conventional commit messages:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `refactor:` for code improvements
   - `test:` for testing changes
   - `docs:` for documentation updates
