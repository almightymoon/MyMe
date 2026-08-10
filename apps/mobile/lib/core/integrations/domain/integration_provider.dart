/// Identifies a device/third-party integration surface in MeMy.
///
/// Add new integrations here first; every other integration type keys off
/// this enum (connections, sync results, errors).
enum IntegrationProvider { calendar, health }
