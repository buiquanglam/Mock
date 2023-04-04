package models

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID          uuid.UUID  `gorm:"primaryKey;default:(UUID())" json:"id,omitempty" `
	CreatedAt   *time.Time `json:"created_at,omitempty"`
	UpdatedAt   *time.Time `json:"updated_at,omitempty"`
	UserName    string     `gorm:"uniqueIndex;not null" json:"user_name"`
	Name        string     `json:"name"`
	Password    string     `json:"password"`
	Email       string     `gorm:"uniqueIndex;not null" json:"email"`
	Phone       string     `gorm:"uniqueIndex;not null" json:"phone"`
	Permissions string     `json:"permissions"`
}
