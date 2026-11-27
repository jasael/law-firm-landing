import { createClient } from '@supabase/supabase-js';

const supabaseUrl =
  import.meta.env.PUBLIC_SUPABASE_URL || 'https://dxrpsovwgrsrombywjsx.supabase.co';
const supabaseAnonKey =
  import.meta.env.PUBLIC_SUPABASE_ANON_KEY ||
  'sb_publishable_O2AKPufH98aI9crT_L6Ckg_RXo2U3BV';

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
