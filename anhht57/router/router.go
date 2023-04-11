package router

import (
	"core/internal/handler"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/monitor"
	"github.com/gofiber/fiber/v2/middleware/pprof"
	"github.com/gofiber/fiber/v2/middleware/recover"
)

var FRouter *fiber.App

// SetupRoutes setup router api
func Setup() {
	app := fiber.New(fiber.Config{
		// Prefork: true,
	})
	FRouter = app
	app.Use(cors.New())
	app.Use(recover.New())
	app.Use(pprof.New())
	app.Get("/dashboard", monitor.New())
	// go handler.ScanAllNotification()

	setupRouter(app)
	app.Listen(":5444")
}

func setupRouter(fiber_app *fiber.App) {
	api := fiber_app.Group("/admin")
	api.Get("/apis.json", handler.GetApis)
	// admin.Post("/register.json", handler.CreateUser)

}
