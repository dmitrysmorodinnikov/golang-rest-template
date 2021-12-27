package config_test

import (
	"github.com/stretchr/testify/assert"
	"golang-rest-template/config"
	"testing"
)

func TestLoadConfig(t *testing.T) {
	c := config.LoadConfig()
	assert.Equal(t, "debug", c.LogLevel())
	assert.Equal(t, "plaintext", c.LogFormat())
}
