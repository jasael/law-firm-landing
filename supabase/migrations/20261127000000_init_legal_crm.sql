-- Migración Inicial: CRM Legal & Triage de Leads
-- Cumplimiento de Confidencialidad y LFPDPPP

-- Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabla Principal de Leads y Expedientes Preliminares
CREATE TABLE IF NOT EXISTS public.legal_leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    firm_id TEXT NOT NULL DEFAULT 'aurelius-asociados',
    case_id TEXT NOT NULL UNIQUE,
    client_name TEXT NOT NULL,
    client_email TEXT NOT NULL,
    client_phone TEXT NOT NULL,
    practice_area TEXT NOT NULL,
    case_status TEXT NOT NULL, -- preventivo, notificado, expediente
    urgency TEXT NOT NULL, -- ordinaria, urgente (<72 hrs)
    modality TEXT NOT NULL, -- presencial, videollamada
    facts_summary TEXT,
    pipeline_status TEXT NOT NULL DEFAULT 'NUEVO', -- NUEVO, CONTACTADO, CITA_AGENDADA, EN_TRAMITE, CONCLUIDO, ARCHIVADO
    assigned_attorney TEXT,
    consultation_fee NUMERIC(10, 2) DEFAULT 0.00,
    is_paid BOOLEAN DEFAULT false
);

-- Tabla de Bitácora y Notas del Abogado
CREATE TABLE IF NOT EXISTS public.lead_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID NOT NULL REFERENCES public.legal_leads(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    author_email TEXT NOT NULL,
    note_content TEXT NOT NULL
);

-- Índices para búsquedas rápidas en el CRM
CREATE INDEX IF NOT EXISTS idx_legal_leads_firm_id ON public.legal_leads(firm_id);
CREATE INDEX IF NOT EXISTS idx_legal_leads_case_id ON public.legal_leads(case_id);
CREATE INDEX IF NOT EXISTS idx_legal_leads_pipeline_status ON public.legal_leads(pipeline_status);
CREATE INDEX IF NOT EXISTS idx_legal_leads_created_at ON public.legal_leads(created_at DESC);

-- HABILITAR ROW LEVEL SECURITY (RLS) - OBLIGATORIO PARA ABOGADOS
ALTER TABLE public.legal_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_notes ENABLE ROW LEVEL SECURITY;

-- 1. Política de Ingesta Pública:
-- Permite que los visitantes de la landing envíen su solicitud sin necesidad de estar logueados
CREATE POLICY "Permitir inserción pública de leads de triage"
ON public.legal_leads
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- 2. Política de Lectura/Modificación del Bufete:
-- Solo personal autenticado (abogados con usuario y contraseña del despacho) puede ver los datos
CREATE POLICY "Acceso exclusivo para abogados autenticados en leads"
ON public.legal_leads
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Acceso exclusivo para abogados autenticados en notas"
ON public.lead_notes
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_legal_leads_updated_at
    BEFORE UPDATE ON public.legal_leads
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();
