package repo

import (
	"core/app"
	"core/internal/models"
)

func CreateAdmin(user models.User) (models.User, error) {
	db := app.Database.DB
	crUser := db.Create(&user)
	return user, crUser.Error
}

func beingtestfunc(t string) string {
	result := t
	return result
}

// func GetAll(user []models.User)  ([]models.User,error) {
// 	db := app.Database.DB
// 	crUser := db.Order("id").Find(&user)
// 	return user, crUser.Error
// }