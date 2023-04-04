package app

import (
	"fmt"
	"os"

	"github.com/ilyakaznacheev/cleanenv"
	"github.com/joho/godotenv"
)

// Config is a application configuration structure
type AppConfig struct {
	Database   DatabaseConfig `yaml:"database"`
	ConfigFile string
}

var Database *DatabaseConfig

func Setup() {

	var Http = &AppConfig{
		ConfigFile: "config.yaml",
	}

	err := godotenv.Load(".env")
	if err != nil {
		fmt.Println(err)
	}
	if err = cleanenv.ReadConfig("config.yaml", Http); err != nil {
		fmt.Println(err)
		os.Exit(2)
	}

	Http.Database.Setup()
	Database = &Http.Database

}

func Config(key string) string {
	value := os.Getenv(key)
	return value
}
