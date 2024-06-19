--População das tabelas para fazer os teste necessarios

INSERT INTO FEDERACAO (NOME, DATA_FUND) VALUES ('Federação A', TO_DATE('2020-01-01', 'YYYY-MM-DD'));
INSERT INTO NACAO (NOME, QTD_PLANETAS, FEDERACAO) VALUES ('Nação A', 3, 'Federação A');
INSERT INTO PLANETA (ID_ASTRO, MASSA, RAIO, CLASSIFICACAO) VALUES ('Planeta A', 5.972, 6371, 'Classe M');
INSERT INTO ESPECIE (NOME, PLANETA_OR, INTELIGENTE) VALUES ('Espécie A', 'Planeta A', 'V');
INSERT INTO LIDER (CPI, NOME, CARGO, NACAO, ESPECIE) VALUES ('123.123.123-10', 'Líder A', 'COMANDANTE', 'Nação A', 'Espécie A');
INSERT INTO FACCAO (NOME, LIDER, IDEOLOGIA, QTD_NACOES) VALUES ('Facção A', '123.123.123-10', 'PROGRESSITA', 1);
INSERT INTO NACAO_FACCAO (NACAO, FACCAO) VALUES ('Nação A', 'Facção A');
INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES ('Planeta A', 'Nação A', TO_DATE('2020-01-01', 'YYYY-MM-DD'));
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Espécie A', 'Comunidade A', 1000);
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('Planeta A', 'Espécie A', 'Comunidade A', TO_DATE('0009-09-09', 'YYYY-MM-DD'));

-- Inserts para terstar oficial
INSERT INTO FEDERACAO (NOME, DATA_FUND) VALUES ('Galactica', DATE '2020-01-01');
INSERT INTO NACAO (NOME, QTD_PLANETAS, FEDERACAO) VALUES ('Andromeda', 2, 'Galactica');
INSERT INTO NACAO (NOME, QTD_PLANETAS, FEDERACAO) VALUES ('Orion', 1, 'Galactica');
INSERT INTO PLANETA (ID_ASTRO, MASSA, RAIO, CLASSIFICACAO) VALUES ('XenonPrime', 5.97, 6371, 'Terrestre');
INSERT INTO PLANETA (ID_ASTRO, MASSA, RAIO, CLASSIFICACAO) VALUES ('Zyphor', 6.42, 3389, 'Terrestre');
INSERT INTO ESPECIE (NOME, PLANETA_OR, INTELIGENTE) VALUES ('Xenonianos', 'XenonPrime', 'V');
INSERT INTO ESPECIE (NOME, PLANETA_OR, INTELIGENTE) VALUES ('Zyphorians', 'XenonPrime', 'V');
INSERT INTO ESPECIE (NOME, PLANETA_OR, INTELIGENTE) VALUES ('Orionites', 'Zyphor', 'V');
INSERT INTO LIDER (CPI, NOME, CARGO, NACAO, ESPECIE) VALUES ('458.123.789-56', 'XenonLider', 'COMANDANTE', 'Andromeda', 'Xenonianos');
INSERT INTO LIDER (CPI, NOME, CARGO, NACAO, ESPECIE) VALUES ('782.456.123-98', 'OrionLider', 'OFICIAL', 'Orion', 'Orionites');
INSERT INTO FACCAO (NOME, LIDER, IDEOLOGIA, QTD_NACOES) VALUES ('Revolucionaria', '458.123.789-56', 'PROGRESSITA', 1);
INSERT INTO NACAO_FACCAO (NACAO, FACCAO) VALUES ('Andromeda', 'Revolucionaria');
INSERT INTO ESTRELA (ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z) VALUES ('EstrelaA', 'AlfaCentauri', 'G2V', 1.0, 0, 0, 0);
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Xenonianos', 'XenonCom', 1000);
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Zyphorians', 'ZyphorCom', 2000);
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Orionites', 'OrionCom', 1500);
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Xenonianos', 'XenonCom');
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Zyphorians', 'ZyphorCom');
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Orionites', 'OrionCom');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('XenonPrime', 'Xenonianos', 'XenonCom', DATE '2021-01-01');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('XenonPrime', 'Zyphorians', 'ZyphorCom', DATE '2021-01-01');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('Zyphor', 'Orionites', 'OrionCom', DATE '2021-01-01');
INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES ('XenonPrime', 'Andromeda', DATE '2021-01-01');
INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES ('Zyphor', 'Orion', DATE '2021-01-01');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('EstrelaA', 'AlfaCentauri');
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('XenonPrime', 'EstrelaA', 147.1, 152.1, 365.25);
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Zyphor', 'EstrelaA', 206.7, 249.2, 687.0);
INSERT INTO PLANETA (ID_ASTRO, MASSA, RAIO, CLASSIFICACAO) VALUES ('Alderaan', 5.98, 6372, 'Terrestre');
INSERT INTO PLANETA (ID_ASTRO, MASSA, RAIO, CLASSIFICACAO) VALUES ('Tatooine', 6.50, 3390, 'Deserto');
INSERT INTO PLANETA (ID_ASTRO, MASSA, RAIO, CLASSIFICACAO) VALUES ('Krypton', 8.30, 5000, 'Gasoso');
INSERT INTO ESPECIE (NOME, PLANETA_OR, INTELIGENTE) VALUES ('Alderaanians', 'Alderaan', 'V');
INSERT INTO ESPECIE (NOME, PLANETA_OR, INTELIGENTE) VALUES ('Tatooinians', 'Tatooine', 'V');
INSERT INTO ESPECIE (NOME, PLANETA_OR, INTELIGENTE) VALUES ('Kryptonians', 'Krypton', 'V');
INSERT INTO LIDER (CPI, NOME, CARGO, NACAO, ESPECIE) VALUES ('654.321.987-00', 'AlderaanLider', 'COMANDANTE', 'Andromeda', 'Alderaanians');
INSERT INTO LIDER (CPI, NOME, CARGO, NACAO, ESPECIE) VALUES ('321.654.987-11', 'TatooineLider', 'OFICIAL', 'Andromeda', 'Tatooinians');
INSERT INTO LIDER (CPI, NOME, CARGO, NACAO, ESPECIE) VALUES ('987.321.654-22', 'KryptonLider', 'CIENTISTA', 'Andromeda', 'Kryptonians');
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Xenonianos', 'XenonCity', 3000);
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Zyphorians', 'ZyphorVillage', 2500);
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Orionites', 'OrionMetropolis', 3500);
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Alderaanians', 'AlderaanCity', 4000);
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Tatooinians', 'TatooineOutpost', 1800);
INSERT INTO COMUNIDADE (ESPECIE, NOME, QTD_HABITANTES) VALUES ('Kryptonians', 'KryptonColony', 2200);
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Xenonianos', 'XenonCity');
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Zyphorians', 'ZyphorVillage');
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Orionites', 'OrionMetropolis');
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Alderaanians', 'AlderaanCity');
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Tatooinians', 'TatooineOutpost');
INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES ('Revolucionaria', 'Kryptonians', 'KryptonColony');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('XenonPrime', 'Xenonianos', 'XenonCity', DATE '2021-01-01');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('XenonPrime', 'Zyphorians', 'ZyphorVillage', DATE '2021-01-01');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('Zyphor', 'Orionites', 'OrionMetropolis', DATE '2021-01-01');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('Alderaan', 'Alderaanians', 'AlderaanCity', DATE '2021-01-01');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('Tatooine', 'Tatooinians', 'TatooineOutpost', DATE '2021-01-01');
INSERT INTO HABITACAO (PLANETA, ESPECIE, COMUNIDADE, DATA_INI) VALUES ('Krypton', 'Kryptonians', 'KryptonColony', DATE '2021-01-01');
INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES ('XenonPrime', 'Andromeda', DATE '2021-01-01');
INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES ('Zyphor', 'Andromeda', DATE '2021-01-01');
INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES ('Alderaan', 'Andromeda', DATE '2021-01-01');
INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES ('Tatooine', 'Andromeda', DATE '2021-01-01');
INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES ('Krypton', 'Andromeda', DATE '2021-01-01');
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Alderaan', 'EstrelaA', 149.6, 150.2, 365.25);
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Tatooine', 'EstrelaA', 207.8, 250.3, 686.0);
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Krypton', 'EstrelaA', 108.2, 111.5, 432.1);


-- inserts para teste dos relatórios de cientista
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('Gl 539', 'Sistema Menkent');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('Zet2Mus', 'Sistema Zet2 Muscae');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('21 Mon', 'Sistema Monocerotis');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('GJ 3579', 'Sistema GJ 3579');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('Del Cae', 'Sistema Delta Caelum');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('Gl 84', 'Sistema Gliese 84');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('Nu Hor', 'Sistema Nu Horologii');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('GJ 1079', 'Sistema GJ 1079');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('GJ 3200', 'Sistema GJ 3200');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('23 Lyn', 'Sistema 23 Lyncis');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('Gl 654.1', 'Sistema Gliese 654.1');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('GJ 3298', 'Sistema GJ 3298');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('50 LMi', 'Sistema 50 Leonis Minoris');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('GJ 3724', 'Sistema GJ 3724');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('46 Cnc', 'Sistema 46 Cancri');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('GJ 3508', 'Sistema GJ 3508');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('Gl 490B', 'Sistema Gliese 490B');
INSERT INTO SISTEMA (ESTRELA, NOME) VALUES ('GJ 3532', 'Sistema GJ 3532');
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Eum iure animi.', 'Gl 539', 0.1, 0.3, 88.0);
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Deserunt aut.', 'Zet2Mus', 0.2, 0.4, 225.0);
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Sequi nisi sed.', 'GJ 3579', 0.4, 0.6, 687.0);
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Minus non.', 'Del Cae', 0.5, 0.7, 433.25);
INSERT INTO ORBITA_ESTRELA (ORBITANTE, ORBITADA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('Gl 84', 'Gl 539', 0.5, 1.0, 365.25);
INSERT INTO ORBITA_ESTRELA (ORBITANTE, ORBITADA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('GJ 1079', 'Zet2Mus', 1.0, 1.5, 687.0);
INSERT INTO ORBITA_ESTRELA (ORBITANTE, ORBITADA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('GJ 3298', 'GJ 3579', 2.0, 2.5, 224.7);
INSERT INTO ORBITA_ESTRELA (ORBITANTE, ORBITADA, DIST_MIN, DIST_MAX, PERIODO) VALUES ('GJ 4055', 'Del Cae', 3.0, 3.5, 365.0);
