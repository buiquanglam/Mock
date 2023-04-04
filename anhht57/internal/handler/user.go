package handler

import (
	"core/internal/models"
	"core/internal/repo"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

func CreateUser(c *fiber.Ctx) error {

	type NewUser struct {
		ID       uuid.UUID `json:"id,omitempty"`
		UserName string    `json:"user_name,omitempty"`
		Email    string    `json:"email,omitempty"`
		Phone    string    `json:"phone,omitempty"`
		Password string    `json:"password,omitempty"`
		Name     string    `json:"name,omitempty"`
	}
	var newuser NewUser
	if err := c.BodyParser(&newuser); err != nil {
		return c.JSON(fiber.Map{"status": false, "message": "Kiểm tra dữ liệu nhập vào", "error": err.Error(), "user": nil})
	}

	if strings.TrimSpace(newuser.Email) == "" || strings.TrimSpace(newuser.UserName) == "" || strings.TrimSpace(newuser.Phone) == "" || strings.TrimSpace(newuser.Password) == "" || strings.TrimSpace(newuser.Name) == "" {
		return c.JSON(fiber.Map{"status": false, "message": "Nhập đầy đủ các trường thông tin", "error": nil, "user": nil})
	}
	hash, err := hashPassword(newuser.Password)
	if err != nil {
		return c.JSON(fiber.Map{"status": false, "message": "Kiểm tra mật khẩu thất bại", "error": err.Error(), "user": nil})
	}
	nUser := models.User{
		UserName:    newuser.UserName,
		Name:        newuser.Name,
		Email:       newuser.Email,
		Phone:       newuser.Phone,
		Password:    hash,
		Permissions: "owner",
	}
	newAdmin, err1 := repo.CreateAdmin(nUser)
	if err1 != nil {
		return c.JSON(fiber.Map{"status": false, "message": "Tạo tài khoản thất bại", "error": err1.Error(), "user": nil})
	}
	adminReturn := NewUser{
		ID:       newAdmin.ID,
		UserName: newAdmin.UserName,
		Email:    newAdmin.Email,
		Phone:    newAdmin.Phone,
		Name:     newAdmin.Name,
	}
	return c.JSON(fiber.Map{"status": true, "message": "Thành công", "error": nil, "user": adminReturn})
}

func hashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 8)
	return string(bytes), err
}

func GetApis(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"status": true, "message": "Thành công", "error": nil})

}

// func GetAll(c *fiber.Ctx) error {
// 	user := []models.User
// 	repo.GetAll(user)
// 	return c.JSON(fiber.Map{"status": true, "message": "Thành công", "error": nil})
// }