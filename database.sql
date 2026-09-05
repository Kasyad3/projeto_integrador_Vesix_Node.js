CREATE DATABASE IF NOT EXISTS estoque_vesix
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE estoque_vesix;

CREATE TABLE IF NOT EXISTS usuario (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(180) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    nivel_acesso ENUM('admin', 'gerente') NOT NULL DEFAULT 'gerente',
    ativo BOOLEAN NOT NULL DEFAULT FALSE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_usuario_email (email),
    KEY idx_usuario_ativo (ativo)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS loja (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_loja_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS usuario_loja (
    usuario_id INT UNSIGNED NOT NULL,
    loja_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (usuario_id, loja_id),
    CONSTRAINT fk_usuario_loja_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_loja_loja
        FOREIGN KEY (loja_id) REFERENCES loja (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Produto (
    id_produto INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(180) NOT NULL,
    sku VARCHAR(80) NOT NULL,
    preco_compra DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    fornecedor_nome VARCHAR(180) NULL,
    PRIMARY KEY (id_produto),
    UNIQUE KEY uq_produto_sku (sku)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS estoque_loja (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_produto INT UNSIGNED NOT NULL,
    id_loja INT UNSIGNED NOT NULL,
    quantidade INT UNSIGNED NOT NULL DEFAULT 0,
    preco_venda DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    data_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_estoque_produto_loja (id_produto, id_loja),
    KEY idx_estoque_loja (id_loja),
    CONSTRAINT fk_estoque_produto
        FOREIGN KEY (id_produto) REFERENCES Produto (id_produto)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_estoque_loja
        FOREIGN KEY (id_loja) REFERENCES loja (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Historico_Estoque (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo_acao ENUM('entrada', 'saida', 'transferencia', 'edicao', 'exclusao') NOT NULL,
    id_produto INT UNSIGNED NULL,
    id_estoque_loja INT UNSIGNED NULL,
    id_loja_origem INT UNSIGNED NULL,
    id_loja_destino INT UNSIGNED NULL,
    quantidade INT UNSIGNED NOT NULL DEFAULT 0,
    usuario_id INT UNSIGNED NULL,
    detalhes JSON NULL,
    data_acao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_historico_data (data_acao),
    KEY idx_historico_tipo (tipo_acao),
    CONSTRAINT fk_historico_produto
        FOREIGN KEY (id_produto) REFERENCES Produto (id_produto)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_historico_estoque
        FOREIGN KEY (id_estoque_loja) REFERENCES estoque_loja (id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_historico_loja_origem
        FOREIGN KEY (id_loja_origem) REFERENCES loja (id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_historico_loja_destino
        FOREIGN KEY (id_loja_destino) REFERENCES loja (id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_historico_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario (id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

INSERT INTO usuario (nome, email, senha, nivel_acesso, ativo)
SELECT 'Administrador', 'admin@vesix.local',
       '$2b$10$kD2gJPk5UPntKku9iiBzd.H7mwDoNJTuEiJWIatss4yOB9p0qiqAS',
       'admin', TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM usuario WHERE email = 'admin@vesix.local'
);

INSERT INTO loja (nome)
SELECT 'Loja Principal'
WHERE NOT EXISTS (
    SELECT 1 FROM loja WHERE nome = 'Loja Principal'
);

INSERT INTO loja (nome)
SELECT 'Loja 1'
WHERE NOT EXISTS (
    SELECT 1 FROM loja WHERE nome = 'Loja 1'
);

INSERT INTO loja (nome)
SELECT 'Loja 2'
WHERE NOT EXISTS (
    SELECT 1 FROM loja WHERE nome = 'Loja 2'
);

INSERT INTO usuario_loja (usuario_id, loja_id)
SELECT u.id, l.id
FROM usuario u
JOIN loja l ON l.nome = 'Loja Principal'
WHERE u.email = 'admin@vesix.local'
  AND NOT EXISTS (
      SELECT 1
      FROM usuario_loja ul
      WHERE ul.usuario_id = u.id AND ul.loja_id = l.id
  );