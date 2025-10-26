


-- ===============================================
-- 1. TABELA EMPRESA
-- ===============================================
CREATE TABLE empresa (
    nro SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(100)
);

-- ===============================================
-- 2. TABELA CONVERSAO
-- ===============================================
CREATE TABLE conversao (
    moeda CHAR(3) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    fator_conver NUMERIC(10,4) NOT NULL
);

-- ===============================================
-- 3. TABELA PAIS
-- ===============================================
CREATE TABLE pais (
    ddi CHAR(3) PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    moeda CHAR(3) NOT NULL REFERENCES conversao(moeda)
);

-- ===============================================
-- 4. TABELA USUARIO
-- ===============================================
CREATE TABLE usuario (
    nick VARCHAR(50) PRIMARY KEY,
    email VARCHAR(120) UNIQUE NOT NULL,
    data_nasc DATE NOT NULL,
    telefone VARCHAR(40),
    end_postal VARCHAR(150),
    pais_residencia CHAR(3) REFERENCES pais(ddi)
);

-- ===============================================
-- 5. TABELA PLATAFORMA
-- ===============================================
CREATE TABLE plataforma (
    nro SERIAL PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    qtd_users INT DEFAULT 0,
    empresa_fund INT REFERENCES empresa(nro),
    empresa_respo INT REFERENCES empresa(nro),
    data_fund DATE
);

-- ===============================================
-- 6. TABELA PLATAFORMA_USUARIO (relacionamento)
-- ===============================================
CREATE TABLE plataforma_usuario (
    id SERIAL PRIMARY KEY,
    nro_plataforma INT REFERENCES plataforma(nro) ON DELETE CASCADE,
    nick_usuario VARCHAR(50) REFERENCES usuario(nick) ON DELETE CASCADE
);

-- ===============================================
-- 7. TABELA STREAMER_PAIS
-- ===============================================
CREATE TABLE streamer_pais (
    id SERIAL PRIMARY KEY,
    nick_streamer VARCHAR(50) REFERENCES usuario(nick),
    ddi_pais CHAR(3) REFERENCES pais(ddi),
    nro_passaporte VARCHAR(20) UNIQUE NOT NULL
);

-- ===============================================
-- 8. TABELA EMPRESA_PAIS
-- ===============================================
CREATE TABLE empresa_pais (
    id SERIAL PRIMARY KEY,
    nro_empresa INT REFERENCES empresa(nro),
    ddi_pais CHAR(3) REFERENCES pais(ddi),
    id_nacional VARCHAR(30) UNIQUE
);

-- ===============================================
-- 9. TABELA CANAL
-- ===============================================
CREATE TABLE canal (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    tipo tipo_canal_enum NOT NULL ,
    data_inicio DATE,
    descricao TEXT,
    qtd_visualizacoes BIGINT DEFAULT 0,
    nick_streamer VARCHAR(50) REFERENCES usuario(nick),
    nro_plataforma INT REFERENCES plataforma(nro),
    UNIQUE (nome, nro_plataforma)
);

-- ===============================================
-- 10. TABELA PATROCINIO
-- ===============================================
CREATE TABLE patrocinio (
    id SERIAL PRIMARY KEY,
    nro_empresa INT REFERENCES empresa(nro),
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    valor NUMERIC(12,2) NOT NULL CHECK (valor >= 0),
    FOREIGN KEY (nome_canal, nro_plataforma) REFERENCES canal(nome, nro_plataforma)
);

-- ===============================================
-- 11. TABELA NIVEL_CANAL
-- ===============================================
CREATE TABLE nivel_canal (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    nivel VARCHAR(30) NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    gif VARCHAR(200),
    FOREIGN KEY (nome_canal, nro_plataforma) REFERENCES canal(nome, nro_plataforma),
    UNIQUE (nome_canal, nro_plataforma, nivel)
);

-- ===============================================
-- 12. TABELA INSCRICAO
-- ===============================================
CREATE TABLE inscricao (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    nick_membro VARCHAR(50) REFERENCES usuario(nick),
    nivel VARCHAR(30) NOT NULL,
    FOREIGN KEY (nome_canal, nro_plataforma, nivel)
      REFERENCES nivel_canal (nome_canal, nro_plataforma, nivel)
);

-- ===============================================
-- 13. TABELA VIDEO
-- ===============================================
CREATE TABLE video (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    dataH TIMESTAMP NOT NULL,
    tema VARCHAR(100),
    duracao INT,
    visu_simul INT DEFAULT 0,
    visu_total INT DEFAULT 0,
    FOREIGN KEY (nome_canal, nro_plataforma)
      REFERENCES canal (nome, nro_plataforma),
    UNIQUE (nome_canal, nro_plataforma, titulo, dataH)
);

-- ===============================================
-- 14. TABELA PARTICIPA
-- ===============================================
CREATE TABLE participa (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    titulo_video VARCHAR(150) NOT NULL,
    dataH_video TIMESTAMP NOT NULL,
    nick_streamer VARCHAR(50) REFERENCES usuario(nick),
    FOREIGN KEY (nome_canal, nro_plataforma, titulo_video, dataH_video)
      REFERENCES video (nome_canal, nro_plataforma, titulo, dataH)
);

-- ===============================================
-- 15. TABELA COMENTARIO
-- ===============================================
CREATE TABLE comentario (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    titulo_video VARCHAR(150) NOT NULL,
    dataH_video TIMESTAMP NOT NULL,
    nick_usuario VARCHAR(50) REFERENCES usuario(nick),
    seq INT NOT NULL,
    texto TEXT NOT NULL,
    dataH TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    coment_on BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (nome_canal, nro_plataforma, titulo_video, dataH_video)
      REFERENCES video (nome_canal, nro_plataforma, titulo, dataH),
    UNIQUE (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq)
);

-- ===============================================
-- 16. TABELA DOACAO
-- ===============================================
CREATE TABLE doacao (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL ,
    titulo_video VARCHAR(150) NOT NULL ,
    dataH_video TIMESTAMP NOT NULL ,
    nick_usuario VARCHAR(50) NOT NULL ,
    seq_comentario INT NOT NULL ,
    seq_pg INT NOT NULL ,
    valor NUMERIC(12,2) NOT NULL CHECK (valor >= 0),
    status status_doacao_enum NOT NULL ,
    FOREIGN KEY (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario)
      REFERENCES comentario (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq),
    UNIQUE (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_pg)
                    );

-- ===============================================
-- 17. TABELAS DE PAGAMENTO (BITCOIN / PAYPAL / CARTAO / MECANISMO_PLAT)
-- ===============================================

CREATE TABLE bitcoin (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    titulo_video VARCHAR(150) NOT NULL,
    dataH_video TIMESTAMP NOT NULL,
    nick_usuario VARCHAR(50) NOT NULL,
    seq_comentario INT NOT NULL,
    seq_doacao INT NOT NULL,
    txid VARCHAR(120) UNIQUE NOT NULL,
    FOREIGN KEY (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_doacao)
      REFERENCES doacao (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_pg)
);

CREATE TABLE paypal (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    titulo_video VARCHAR(150) NOT NULL,
    dataH_video TIMESTAMP NOT NULL,
    nick_usuario VARCHAR(50) NOT NULL,
    seq_comentario INT NOT NULL,
    seq_doacao INT NOT NULL,
    idpaypal VARCHAR(120) UNIQUE NOT NULL,
    FOREIGN KEY (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_doacao)
      REFERENCES doacao (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_pg)
);

CREATE TABLE cartaocredito (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    titulo_video VARCHAR(150) NOT NULL,
    dataH_video TIMESTAMP NOT NULL,
    nick_usuario VARCHAR(50) NOT NULL,
    seq_comentario INT NOT NULL,
    seq_doacao INT NOT NULL,
    nro VARCHAR(30) NOT NULL,
    bandeira VARCHAR(20),
    FOREIGN KEY (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_doacao)
      REFERENCES doacao (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_pg)
);

CREATE TABLE mecanismo_plat (
    id SERIAL PRIMARY KEY,
    nome_canal VARCHAR(80) NOT NULL,
    nro_plataforma INT NOT NULL,
    titulo_video VARCHAR(150) NOT NULL,
    dataH_video TIMESTAMP NOT NULL,
    nick_usuario VARCHAR(50) NOT NULL,
    seq_comentario INT NOT NULL,
    seq_doacao INT NOT NULL,
    seq_plataforma INT NOT NULL,
    FOREIGN KEY (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_doacao)
      REFERENCES doacao (nome_canal, nro_plataforma, titulo_video, dataH_video, nick_usuario, seq_comentario, seq_pg)
);

