export interface PracticeArea {
  id: string;
  name: string;
}

export interface FirmConfig {
  id: string;
  name: string;
  tagline: string;
  phone: string;
  whatsapp: string; // Número con lada internacional sin símbolos (ej. 521...)
  email: string;
  address: string;
  theme: {
    primaryColor: string;
    accentColor: string;
  };
  practiceAreas: PracticeArea[];
}

export const firmConfig: FirmConfig = {
  id: "aurelius-asociados",
  name: "Aurelius & Asociados",
  tagline: "Bufete Jurídico Especializado",
  phone: "+52 55 4456 8319",
  whatsapp: "525544568319", // Número configurado para triage WhatsApp
  email: "contacto@aurelius.com",
  address: "Centro Histórico, Texcoco, Estado de México",
  theme: {
    primaryColor: "#0b0f19",
    accentColor: "#c5a059",
  },
  practiceAreas: [
    { id: "corporativo", name: "Derecho Corporativo & Mercantil" },
    { id: "familiar", name: "Derecho Familiar, Divorcios & Sucesiones" },
    { id: "penal", name: "Defensa Penal Estratégica" },
    { id: "laboral", name: "Litigio Laboral Patronal / Empleados" },
    { id: "amparo", name: "Amparo & Juicios Constitucionales" },
    { id: "inmobiliario", name: "Derecho Inmobiliario & Contratos" },
    { id: "fiscal", name: "Defensa Fiscal & Administrativa" },
    { id: "otros", name: "Otro Asunto Jurídico" },
  ],
};
