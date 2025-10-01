# Contributing to Compliance as Code

We're building this in public and welcome contributions!

## Ways to Contribute

### 1. Add a New Compliance Framework

Define controls for a framework not yet supported (CCPA, NIST CSF, etc.):

1. Create `frameworks/{framework}/controls/default.nix`
2. Use `schema.nix` to define controls with `mkControl`
3. Map controls to canonical objectives from `taxonomy.nix`
4. Add generators to `frameworks/generators/flake.nix`
5. Test code generation: `nix build .#java-{framework}`

See **[frameworks/README.md](./frameworks/README.md)** for details.

### 2. Add Language Support

Currently supporting Java, TypeScript, Python, Go, Nix. Want to add:
- Rust (procedural macros for `#[gdpr_evidence]`)
- C# (attributes)
- Ruby (decorators)
- Elixir (function wrappers)
- Other languages?

1. Extend `schema.nix` with language patterns
2. Add generator function to `frameworks/generators/flake.nix`
3. Emit OpenTelemetry spans with compliance attributes
4. Add example to `examples/`

### 3. Create Working Examples

Help others by showing how to integrate with:
- **Backend frameworks**: Django, Rails, Phoenix, Laravel, etc.
- **Frontend frameworks**: React, Vue, Angular, Svelte, etc.
- **Data tools**: Snowflake, BigQuery, Databricks, dbt, etc.
- **Infrastructure**: Terraform, Pulumi, Kubernetes operators, etc.

See **[examples/README.md](./examples/README.md)** for structure.

### 4. Improve Documentation

- Add more real-world examples
- Explain canonical taxonomy patterns
- Create integration guides
- Add troubleshooting sections

### 5. Report Issues

Found a bug? Control definition incorrect? Generator producing bad code?

Open an issue with:
- Description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Nix version)

## Development Setup

### Prerequisites

- **Nix with flakes enabled**:
  ```bash
  # macOS/Linux
  sh <(curl -L https://nixos.org/nix/install) --daemon

  # Enable flakes
  mkdir -p ~/.config/nix
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  ```

### Clone and Build

```bash
git clone https://github.com/fluohq/compliance-as-code.git
cd compliance-as-code

# Build all generators
nix build .#all

# Build specific generator
nix build .#java-gdpr

# Run tests
nix flake check
```

### Project Structure

```
compliance-as-code/
├── frameworks/
│   ├── schema.nix           # Control definition schema
│   ├── taxonomy.nix         # Canonical security objectives
│   ├── gdpr/               # GDPR controls
│   ├── soc2/               # SOC 2 controls
│   ├── hipaa/              # HIPAA controls
│   ├── fedramp/            # FedRAMP controls
│   ├── iso27001/           # ISO 27001 controls
│   ├── pci-dss/            # PCI-DSS controls
│   └── generators/
│       └── flake.nix       # Code generation
└── examples/
    ├── backend/            # Framework examples
    ├── frontend/           # UI framework examples
    ├── data/               # Data tool examples
    └── infrastructure/     # IaC examples
```

### Adding a Control

1. Find or create framework directory: `frameworks/{framework}/controls/`
2. Define control using `mkControl`:

```nix
{ schema }:
let
  inherit (schema) mkControl evidenceTypes riskLevels technicalControlTypes;
in
{
  myControl = mkControl {
    id = "CTRL-1";
    name = "My Control";
    category = "Security Category";
    description = ''
      What this control requires...
    '';
    requirements = [
      "Specific requirement 1"
      "Specific requirement 2"
    ];
    evidenceTypes = [ evidenceTypes.AUDIT_TRAIL ];
    riskLevel = riskLevels.HIGH;
    technicalControls = [ technicalControlTypes.ACCESS_CONTROL ];
    canonicalObjectives = [ "IAM.AUTH.VERIFY.UNIQUE_ID" ];
    implementationGuidance = ''
      How to implement this control...
    '';
    testingProcedures = [
      "How to test this control..."
    ];
    metadata = {
      tags = [ "technical" "access-control" ];
      automatable = true;
    };
  };

  allControls = [ myControl ];
}
```

3. Test generation:
```bash
cd frameworks/generators
nix build .#java-{framework}
```

### Code Generation

Generators transform Nix control definitions into target languages:

```nix
# frameworks/generators/flake.nix
generateJava = controls: frameworkName:
  # Takes list of controls
  # Emits Java annotations, constants, documentation

generateGo = controls: frameworkName:
  # Takes list of controls
  # Emits Go context functions, control constants
```

### Testing Examples

```bash
# Test specific example
cd examples/backend/java-spring-boot
nix build

# Run example
nix run
```

## Pull Request Guidelines

1. **Keep changes focused**: One feature/fix per PR
2. **Write clear commit messages**: Explain why, not just what
3. **Test your changes**: Run `nix flake check`
4. **Update documentation**: Add examples, update READMEs
5. **Follow existing patterns**: Match code style and structure

### PR Title Format

```
feat: Add Rust language support
fix: Correct GDPR Art.17 requirements
docs: Add NestJS integration example
chore: Update flake inputs
```

## Code of Conduct

Be respectful, inclusive, and constructive. We're all learning.

See **[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)** for details.

## Questions?

- Open a discussion on GitHub
- Check existing issues and PRs
- Read the documentation in `frameworks/`

## License

By contributing, you agree your contributions will be licensed under the Apache 2.0 License.

---

**Thank you for helping make compliance observable infrastructure!**
