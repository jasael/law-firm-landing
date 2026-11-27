-- Migration: 20261127010000_rag_schema.sql
-- Description: Schema for Legal Case RAG with pgvector embeddings

CREATE EXTENSION IF NOT EXISTS vector;

-- 1. Table for Case Documents (PDFs, files attached to a case)
CREATE TABLE IF NOT EXISTS case_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_size BIGINT NOT NULL,
  file_type TEXT DEFAULT 'application/pdf',
  total_pages INT DEFAULT 1,
  status TEXT DEFAULT 'COMPLETED' CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_case_documents_case_id ON case_documents(case_id);

-- 2. Table for Document Chunks with 384-dim embeddings (MiniLM / BGE-small)
CREATE TABLE IF NOT EXISTS document_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES case_documents(id) ON DELETE CASCADE,
  case_id TEXT NOT NULL,
  page_number INT NOT NULL DEFAULT 1,
  chunk_index INT NOT NULL,
  content TEXT NOT NULL,
  embedding vector(384) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_document_chunks_case_id ON document_chunks(case_id);
CREATE INDEX IF NOT EXISTS idx_document_chunks_doc_id ON document_chunks(document_id);

-- HNSW Vector Index for fast cosine similarity search
CREATE INDEX IF NOT EXISTS idx_document_chunks_hnsw 
ON document_chunks 
USING hnsw (embedding vector_cosine_ops);

-- 3. Stored Procedure for Semantic Case Search (Retrieval)
CREATE OR REPLACE FUNCTION match_document_chunks(
  query_embedding vector(384),
  match_case_id TEXT,
  match_count INT DEFAULT 5,
  similarity_threshold FLOAT DEFAULT 0.25
)
RETURNS TABLE (
  id UUID,
  document_id UUID,
  page_number INT,
  content TEXT,
  similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    dc.id,
    dc.document_id,
    dc.page_number,
    dc.content,
    1 - (dc.embedding <=> query_embedding) AS similarity
  FROM document_chunks dc
  WHERE dc.case_id = match_case_id
    AND 1 - (dc.embedding <=> query_embedding) >= similarity_threshold
  ORDER BY dc.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;
