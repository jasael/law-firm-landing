import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM0NDk2MDB9.CRXP1A_dummy_key_for_local_development';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface LegalLeadPayload {
  firm_id: string;
  case_id: string;
  client_name: string;
  client_email: string;
  client_phone: string;
  practice_area: string;
  case_status: string;
  urgency: string;
  modality: string;
  facts_summary: string;
}

/**
 * Guarda un lead calificado de triage en Supabase.
 * Falla de forma silenciosa/resiliente para nunca bloquear el flujo de WhatsApp del cliente.
 */
export async function saveLegalLead(payload: LegalLeadPayload): Promise<{ success: boolean; error?: string }> {
  try {
    const { error } = await supabase.from('legal_leads').insert([payload]);
    if (error) {
      console.warn('Advertencia al guardar en Supabase (modo offline/resiliente):', error.message);
      return { success: false, error: error.message };
    }
    return { success: true };
  } catch (err) {
    console.warn('Error de red al conectar con Supabase:', err);
    return { success: false, error: String(err) };
  }
}
