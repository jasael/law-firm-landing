-- Migration: 20261127020000_whatsapp_sessions.sql
-- Description: State machine sessions for WhatsApp conversational legal triage

CREATE TABLE IF NOT EXISTS whatsapp_sessions (
  phone_number TEXT PRIMARY KEY,
  client_name TEXT,
  step TEXT NOT NULL DEFAULT 'GREETING' CHECK (step IN ('GREETING', 'AWAITING_NAME', 'AWAITING_AREA', 'AWAITING_URGENCY', 'AWAITING_FACTS', 'COMPLETED')),
  practice_area TEXT,
  case_status TEXT,
  urgency TEXT,
  facts_summary TEXT,
  case_id TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_whatsapp_sessions_updated ON whatsapp_sessions(updated_at DESC);

GRANT ALL ON whatsapp_sessions TO anon, authenticated, service_role;
