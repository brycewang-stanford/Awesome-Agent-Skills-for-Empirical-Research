# Security Review Guide

## Check for
- unsanitized input,
- SQL or shell injection,
- insecure deserialization,
- secret leakage,
- missing authz checks,
- unsafe filesystem or network defaults.

## Review note pattern
`Blocking: this path accepts untrusted input and passes it to X without validation.`
