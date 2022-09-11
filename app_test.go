package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

type addTest struct {
	arg1, arg2, expected int
}

var addTests = []addTest{
	{2, 3, 5},
	{4, 8, 12},
	{6, 9, 15},
	{3, 10, 13},
}

func TestSum(t *testing.T) {
	for _, testCase := range addTests {
		assert.Equal(t, testCase.expected, add(testCase.arg1, testCase.arg2))
	}
}
