package kdiff

import (
	"fmt"
	"os"

	"github.com/rajamohan-rj/kdiff/internal/differ"
	"github.com/spf13/cobra"
)

var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
	opts    differ.Options
)

var rootCmd = &cobra.Command{
	Use:   "kdiff <namespace1> <resource1> <namespace2> <resource2>",
	Short: "Kubernetes resource differ",
	Long: `kdiff is a tool to compare Kubernetes resources between different namespaces.

Features:
  • Compare Kubernetes resources between any two namespaces
  • Colored diff output for better readability
  • Optional kubectl neat integration to clean output
  • Multiple output formats (unified, context, side-by-side)
  • Support for all Kubernetes resource types
  • Verbose logging for debugging

Examples:
  # Compare deployments between staging and production
  kdiff staging my-app production my-app

  # Compare services with verbose output
  kdiff --verbose dev my-service prod my-service

  # Compare without colored output
  kdiff --no-color namespace1 deployment/app namespace2 deployment/app

  # Use context diff format
  kdiff --output context ns1 svc/api ns2 svc/api

  # Compare with side-by-side format and skip kubectl neat
  kdiff --output side-by-side --no-neat ns1 pod/web ns2 pod/web

Prerequisites:
  • kubectl command-line tool
  • kubectl neat plugin (optional, for cleaner YAML output)
  • colordiff (optional, for colored output)`,
	Args: cobra.ExactArgs(4),
	Run: func(cmd *cobra.Command, args []string) {
		opts.Namespace1 = args[0]
		opts.Resource1 = args[1]
		opts.Namespace2 = args[2]
		opts.Resource2 = args[3]

		if err := differ.Run(opts); err != nil {
			fmt.Fprintln(os.Stderr, "Error:", err)
			os.Exit(1)
		}
	},
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version number",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("kdiff %s (commit %s, built %s)\n", version, commit, date)
	},
}

func init() {
	rootCmd.Flags().BoolVar(&opts.NoColor, "no-color", false, "disable colored output (useful for CI/CD pipelines)")
	rootCmd.Flags().BoolVar(&opts.NoNeat, "no-neat", false, "skip kubectl neat processing (show raw YAML)")
	rootCmd.Flags().StringVar(&opts.OutputFormat, "output", "unified", "output format: unified, context, side-by-side")
	rootCmd.Flags().BoolVar(&opts.Verbose, "verbose", false, "enable verbose logging for debugging")

	// Add version flag that shows version and exits
	rootCmd.Flags().BoolP("version", "v", false, "show version information")
	rootCmd.SetVersionTemplate("kdiff {{.Version}} (commit " + commit + ", built " + date + ")\n")
	rootCmd.Version = version

	// Add version subcommand
	rootCmd.AddCommand(versionCmd)
}

// Execute runs the root command - called from main.go
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
