package config

import (
	"github.com/spf13/viper"
)

// Config is the system config
type Config interface {
	LogLevel() string
	LogFormat() string
}

type config struct {
	logLevel  string
	logFormat string
}

// LoadConfig returns values for the config
func LoadConfig() Config {
	vp := newWithViper()
	return config{
		logLevel:  vp.GetString("LOG_LEVEL"),
		logFormat: vp.GetString("LOG_FORMAT"),
	}
}

// LogLevel return log level config
func (c config) LogLevel() string {
	return c.logLevel
}

// LogFormat returns log format config
func (c config) LogFormat() string {
	return c.logFormat
}

func newWithViper() *viper.Viper {
	vp := viper.New()
	vp.AutomaticEnv()
	vp.SetConfigName("application")
	vp.AddConfigPath("./")
	vp.AddConfigPath("../")
	vp.AddConfigPath("../../")
	vp.ReadInConfig()
	return vp
}
