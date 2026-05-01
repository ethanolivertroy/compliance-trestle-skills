# Acme Analytics Platform System Security Plan

Version: 0.3 synthetic example
System Owner: Jane Example, Director of Platform Security
Information System Security Officer: Pat Example

## System Description

Acme Analytics Platform is a synthetic multi-tenant analytics service used for demonstration. The system processes test telemetry, generated customer-like records, and operational logs. No real customer data is included in this example.

## Boundary

The authorization boundary includes the web application, API service, worker service, PostgreSQL database, object storage bucket, CI/CD repository, and cloud logging project. Corporate identity provider and external ticketing system are inherited services outside the boundary.

## Users

The system has three user groups: platform administrators, tenant administrators, and read-only analysts.

## AC-2 Account Management

User accounts are provisioned through the corporate identity provider. Administrative access requires approval in the ticketing system. Accounts are reviewed quarterly by the system owner and disabled after termination notifications.

## IA-2 Identification and Authentication

All interactive users authenticate with SSO and phishing-resistant MFA where available. Service accounts use short-lived workload identity tokens.

## SC-13 Cryptographic Protection

Data in transit uses TLS 1.2 or higher. Data at rest is encrypted with cloud-managed keys. The team plans to evaluate customer-managed keys in the next release.

## AU-2 Event Logging

The application logs authentication events, administrative actions, configuration changes, and data export requests. Logs are forwarded to the central security logging project.

## Open Items

The original SSP did not include a current network diagram. The system owner must provide a reviewed diagram before authorization package submission.
