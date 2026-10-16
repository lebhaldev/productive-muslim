CREATE statements of each released database schema, as a phone would have them.
`test/migration_test.dart` builds an old database from these and checks it upgrades
to the current schema with its data. When `schemaVersion` goes up, add the new
`vN.sql` (dump `sqlite_master` from a fresh database) and a test from the previous one.
