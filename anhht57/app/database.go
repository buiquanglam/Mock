package app

// import (
// 	"core/internal/model"
// 	"fmt"
// 	"log"
// 	"os"
// 	"time"

// 	"github.com/sirupsen/logrus"
// 	"gorm.io/driver/mysql"
// 	"gorm.io/gorm"
// 	"gorm.io/gorm/logger"
// )

// type DatabaseConfig struct {
// 	*gorm.DB
// 	Driver      string `yaml:"driver" env:"DB_DRIVER"`
// 	Host        string `yaml:"host" env:"DB_HOST"`
// 	Username    string `yaml:"username" env:"DB_USER"`
// 	Password    string `yaml:"password" env:"DB_PASSWORD"`
// 	DBName      string `yaml:"db_name" env:"DB_NAME"`
// 	Port        int    `yaml:"port" env:"DB_PORT"`
// 	Connections int    `yaml:"connections" env:"DB_CONNECTIONS"`
// 	Debug       bool   `yaml:"debug"`
// }

// func (cg *DatabaseConfig) Setup() {
// 	logrus.SetLevel(logrus.DebugLevel)
// 	newLogger := logger.New(
// 		log.New(os.Stdout, "\r\n", log.LstdFlags), // io writer
// 		logger.Config{
// 			SlowThreshold:             time.Second,   // Slow SQL threshold
// 			LogLevel:                  logger.Silent, // Log level
// 			IgnoreRecordNotFoundError: true,          // Ignore ErrRecordNotFound error for logger
// 			Colorful:                  false,         // Disable color
// 		},
// 	)
// 	mainDbDNS := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local", cg.Username, cg.Password, cg.Host, cg.Port, cg.DBName)
// 	DB, err := gorm.Open(
// 		mysql.New(mysql.Config{
// 			DSN:               mainDbDNS,
// 			DefaultStringSize: 256, // default size for string fields
// 		}),
// 		&gorm.Config{
// 			PrepareStmt: true,
// 			Logger:      newLogger,
// 		})

// 	if cg.Debug {
// 		DB = DB.Debug()
// 	}
// 	cg.DB = DB
// 	if err != nil {
// 		panic("Failed to connect database")
// 	}
// 	if error := DB.AutoMigrate(&model.User{}); err != error {
// 		logrus.Debug(error)
// 	}
// 	logrus.Info("Migration finish")
// }
