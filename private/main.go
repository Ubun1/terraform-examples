// +build codegen

// Command aws-gen-gocli parses a JSON description of an AWS API and generates a
// Go file containing a client for the API.
//
//     aws-gen-gocli apis/s3/2006-03-03/api-2.json
package main

import (
  "os"
  "text/template"
  "path/filepath"
)


type TemplateVars struct {
  CaseName string
}

func main() {
  searchDir := "../cases"

  folderList := []string{}
  filepath.Walk(searchDir, func(path string, f os.FileInfo, err error) error {
      if f.IsDir() && f.Name() == "cases" {
        return nil
      }
      if f.IsDir() {
        folderList = append(folderList, path)
      }
      return nil
  })

  for _, folder := range folderList {
    pwd, _ := os.Getwd()
    filename := folder + "/" + filepath.Base(folder) + "_test.go"
    file, _ := os.Create(filename)

    d := TemplateVars{filepath.Base(folder)}

    t := template.Must(template.New("template").Parse(templatestr))
    t.Execute(file, d)

    os.Symlink(pwd + "/../.terraform", folder + "/.terraform")
    os.Symlink(pwd + "/../terraform.tfvars", folder + "/terraform.tfvars")
    os.Symlink(pwd + "/../main.tf", folder + "/provider.tf")
  }
}

var templatestr =  `
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func Test_{{ .CaseName }}(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
    TerraformDir: ".",

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"terraform.tfvars"},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.Apply(t, terraformOptions)
  assert.Equal(t, true, true)
}
`
