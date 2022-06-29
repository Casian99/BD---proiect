CREATE TABLE circuit(
  id_circuit NUMBER(5),
  nume_circuit VARCHAR2(60) NOT NULL,
  lungime NUMBER(15) NOT NULL,
  oras VARCHAR2(50) NOT NULL,
  tara VARCHAR2(50) NOT NULL,
  CONSTRAINT pk_circuit PRIMARY KEY (id_circuit)
);

CREATE TABLE grandprix(
  id_grandprix NUMBER(5) NOT NULL,
  data DATE,
  CONSTRAINT pk_grandprix PRIMARY KEY (id_grandprix)
);

ALTER TABLE grandprix ADD id_circuit NUMBER(5);
ALTER TABLE grandprix ADD FOREIGN KEY (id_circuit) REFERENCES circuit(id_circuit);



CREATE TABLE echipa(
  nume_echipa VARCHAR2(50) NOT NULL,
  buget NUMBER(10),
  CONSTRAINT pk_echipa PRIMARY KEY (nume_echipa)
);
ALTER TABLE echipa ADD numar_piloti NUMBER(10) default 0 NOT NULL;

CREATE TABLE piloti(
  numar_pilot NUMBER(4),
  nume_pilot VARCHAR2(50),
  prenume_pilot VARCHAR2(50),
  varsta NUMBER(2),
  CONSTRAINT pk_pilot PRIMARY KEY (numar_pilot)
);

ALTER TABLE piloti ADD nume_echipa VARCHAR2(50);
ALTER TABLE piloti ADD FOREIGN KEY (nume_echipa) REFERENCES echipa(nume_echipa);

CREATE TABLE sponsor_principal(
  nume_sponsor VARCHAR2(40),
  buget NUMBER(4),
  nume_echipa VARCHAR2(50) UNIQUE,      
  CONSTRAINT pk_sponsor PRIMARY KEY (nume_sponsor)
);
ALTER TABLE sponsor_principal ADD FOREIGN KEY (nume_echipa) REFERENCES echipa(nume_echipa);

CREATE TABLE motor(
  id_motor NUMBER(5), 
  valoare NUMBER(4),
  nume_echipa VARCHAR2(50) UNIQUE,    
  CONSTRAINT pk_motor PRIMARY KEY (id_motor)
);
ALTER TABLE motor ADD FOREIGN KEY (nume_echipa) REFERENCES echipa(nume_echipa);

CREATE TABLE cursa(
  id_cursa NUMBER(5),
  id_castigator NUMBER(4),
  premiu NUMBER(4),
  nume_echipa VARCHAR2(50),
  id_circuit NUMBER(5),
  CONSTRAINT fk_nume_echipa FOREIGN KEY (nume_echipa) REFERENCES echipa(nume_echipa), 
  CONSTRAINT fk_id_castigator FOREIGN KEY (id_castigator) REFERENCES piloti(numar_pilot), 
  CONSTRAINT fk_id_circuit FOREIGN KEY (id_circuit) REFERENCES circuit(id_circuit),
  CONSTRAINT pk_cursa PRIMARY KEY (id_cursa)
);


-- POPULARE

--CIRCUIT:

INSERT INTO circuit VALUES(1,'Adelaide',3780,'Adelaide','Australia');
INSERT INTO circuit VALUES(2,'Aintree',4828,'Liverpool','Anglia');
INSERT INTO circuit VALUES(3,'Albert Park',5303,'Melbourne','Australia');
INSERT INTO circuit VALUES(4,'Austin Park',5470,'Austin','USA');
INSERT INTO circuit VALUES(5,'International Bahrain',5412,'Sakhir','Bahrain');
INSERT INTO circuit VALUES(6,'Hungaroring',4381,'Budapesta','Ungaria');

--ECHIPA:


INSERT INTO echipa(nume_echipa,buget) VALUES('Mercedes',20);
INSERT INTO echipa(nume_echipa,buget) VALUES('Red Bull',16);
INSERT INTO echipa(nume_echipa,buget) VALUES('Mclaren',14);
INSERT INTO echipa(nume_echipa,buget) VALUES('Ferarri',13);
INSERT INTO echipa(nume_echipa,buget) VALUES('Alfaromeo',12);

--MOTOR:
INSERT INTO motor VALUES(1,256,'Mercedes');
INSERT INTO motor VALUES(2,351,'Red Bull');
INSERT INTO motor VALUES(3,39,'Ferarri');
INSERT INTO motor VALUES(4,413,'Mclaren');
INSERT INTO motor VALUES(5,234,'Alfaromeo');




--PILOTI:


INSERT INTO piloti VALUES(44,'Lewis','Hamilton',36,'Mercedes');
INSERT INTO piloti VALUES(77,'Valteri','Bottas',32,'Mercedes');
INSERT INTO piloti VALUES(33,'Max','Verstappen',24,'Red Bull');
INSERT INTO piloti VALUES(11,'Checo','Perez',26,'Red Bull');
INSERT INTO piloti VALUES(4,'Lando','Norris',22,'Mclaren');
INSERT INTO piloti VALUES(3,'Daniel','Ricciardo',27,'Mclaren');
INSERT INTO piloti VALUES(55,'Carlos','Sainz',26,'Ferarri');
INSERT INTO piloti VALUES(16,'Charles','Leclerc',24,'Ferarri');




--SPONSOR PRINCIPAL:



INSERT INTO sponsor_principal VALUES('Petronas',786,'Ferarri');
INSERT INTO sponsor_principal VALUES('Team Viewer',812,'Mercedes');
INSERT INTO sponsor_principal VALUES('Oracle',689,'Red Bull');
INSERT INTO sponsor_principal VALUES('Crypto.com',786,'Mclaren');
INSERT INTO sponsor_principal VALUES('EGC',45,'Alfaromeo');







--GRAND PRIX:


INSERT INTO grandprix VALUES(1,'02-MAR-2022',1);
INSERT INTO grandprix VALUES(2,'14-APR-2022',4);
INSERT INTO grandprix VALUES(3,'21-JUN-2022',3);
INSERT INTO grandprix VALUES(4,'11-AUG-2022',2);
INSERT INTO grandprix VALUES(5,'25-OCT-2022',6);
INSERT INTO grandprix VALUES(6,'08-DEC-2022',5);



--CURSA:

INSERT INTO cursa VALUES(1,44,113,'Mercedes',1); 
INSERT INTO cursa VALUES(2,33,150,'Red Bull',2); 
INSERT INTO cursa VALUES(3,4,121,'Mclaren',3); 
INSERT INTO cursa VALUES(4,44,136,'Mercedes',4); 
INSERT INTO cursa VALUES(5,55,125,'Ferarri',5); 
INSERT INTO cursa VALUES(6,11,106,'Red Bull',6);
INSERT INTO cursa VALUES(7,16,134,'Ferarri',2);
INSERT INTO cursa VALUES(8,4,200,'Mclaren',5);
INSERT INTO cursa VALUES(9,33,182,'Red Bull',1);
INSERT INTO cursa VALUES(10,77,166,'Mercedes',3);

select * from circuit;

select * from echipa;

select * from motor;

select * from piloti;

select * from sponsor_principal;

select * from grandprix;

select * from cursa;


-- Sa se afiseze pilotii care au castigat cel putin x curse, unde x este un numar citit de la tastatura.
-- Se vor afisa detalii despre pilot, motorul folosit, sponsorul principal si numarul curselor castigate.
WITH castigatori AS
    (SELECT id_castigator, COUNT(*) AS cnt
     FROM cursa c
     GROUP BY id_castigator)
SELECT DISTINCT castigatori.id_castigator, p.nume_pilot, p.prenume_pilot, m.id_motor, m.valoare, cu.nume_echipa, sp.nume_sponsor, castigatori.cnt AS WON
FROM castigatori
JOIN cursa cu ON castigatori.id_castigator = cu.id_castigator
JOIN piloti p ON cu.id_castigator = p.numar_pilot
JOIN sponsor_principal sp ON cu.nume_echipa = sp.nume_echipa
JOIN motor m ON cu.nume_echipa = m.nume_echipa
WHERE castigatori.cnt >= &x;




-- O echipa este premiata special de sponsor daca aceasta obtine rezultate de catre un pilot 
-- ce a utilizat acelasi motor.
WITH pm AS
(SELECT id_castigator, valoare, COUNT(*) AS cnt
FROM cursa C
JOIN motor M ON C.nume_echipa = M.nume_echipa
GROUP BY id_castigator, valoare)
SELECT DISTINCT pm.id_castigator, nume_pilot, prenume_pilot, M.id_motor, M.valoare, P.nume_echipa, sp.nume_sponsor, pm.cnt AS WON
FROM pm 
JOIN cursa cu ON pm.id_castigator = cu.id_castigator
JOIN piloti P ON cu.id_castigator = P.numar_pilot
JOIN sponsor_principal sp ON cu.nume_echipa = sp.nume_echipa
JOIN motor M ON cu.nume_echipa = M.nume_echipa
WHERE pm.cnt > 1;



--informatii despre grandprix-urile care au loc in orasul Budapesta, care au numele format din cel putin 4 litere,
--care au loc intr-o data cu un numar de luni intre data si 01.07.2022 de cel mult 3.
select g.data, c.nume_circuit, c.oras, c.tara
from grandprix g
join circuit c on g.id_circuit = c.id_circuit
where length(c.nume_circuit) > 4 and upper(c.oras) = 'BUDAPESTA' and months_between(to_date('01-07-2022','dd-mm-yyyy'), g.data)<3;


update echipa 
set numar_piloti = 2;
insert into echipa(nume_echipa,buget) values('Alpine',15);
select * from echipa;

--afisati un mesaj de genul : Echipa ... are un numar de piloti de .... cu buget .... In ordine crescatoare dupa buget. Daca nu are piloti se va afisa mesaj
--corespunzator.
select 'Echipa ' || nume_echipa || case when numar_piloti = 0 then ' nu are niciun pilot' else (' e formata din ' || numar_piloti || ' piloti') 
end || ' si are un buget de ' || buget || ' lei.' as mesaj
from echipa
order by buget;




update piloti
set varsta = null
where nume_pilot = 'Lewis';

--informatii despre pilotii care au castigat cel putin o cursa, din echipa Mercedes, cu un motor ce valoreaza mai mult de 250 lei?. (nume, prenume, id, varsta).
select p.nume_pilot || ' ' || p.prenume_pilot || ' cu id-ul ' || p.numar_pilot || decode(nvl(p.varsta,0),0, ' nu are varsta setata', ' in varsta de ' || p.varsta || ' ani') as mesaj
from piloti p
where p.numar_pilot in (select c.id_castigator
                        from cursa c, echipa e, motor m
                        where c.id_castigator = p.numar_pilot and c.nume_echipa = e.nume_echipa and e.nume_echipa = m.nume_echipa and upper(e.nume_echipa) = 'MERCEDES' 
                        and m.valoare > 250);
                        
                        
                    


-- vom actualiza bugetul prin marirea acestora cu 75% echipelor care incep cu litera 'M'.
update echipa e
set e.buget = e.buget+e.buget*0.75
where e.nume_echipa in (select p.nume_echipa from piloti p where lower(p.nume_echipa) like 'm%');

-- vom seta bugetul sponsorilor principali la 800, acelora care au cel putin lungimea numelui 8.
update sponsor_principal sp
set sp.buget = 800
where sp.nume_echipa in (select e.nume_echipa from echipa e where length(e.nume_echipa)> 7); 

-- vom sterge toate cursele care au avut loc in tara Australia.
delete from cursa cu
where cu.id_circuit not in ( select c.id_circuit from circuit c where upper(c.tara) like 'AUSTRALIA');
 
select * from sponsor_principal;
select * from cursa;


