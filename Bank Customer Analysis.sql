/*
       Bank Customer Analysis
      
*/

/*

       -- Age
		---------------------------------------------------------------------------------

*/

USE banca;

CREATE TEMPORARY TABLE banca.eta AS
SELECT 
clt.id_cliente, 
CAST(YEAR(CURRENT_DATE()) - YEAR(data_nascita) AS SIGNED) AS eta
FROM banca.cliente clt;


/*
       
        -- Number of outgoing transactions on all accounts
        -- Number of incoming transactions on all accounts
        -- Amount transacted out on all accounts
        -- Amount transacted in on all accounts
       ---------------------------------------------------------------------------------
       
*/

CREATE TEMPORARY TABLE banca.trans AS
SELECT
clt.id_cliente,
count(CASE WHEN segno = '-' THEN 1 END) AS  transazioni_uscita,
count(CASE WHEN segno = '+' THEN 1 END) AS transazioni_entrata,
round(sum(CASE WHEN segno = '+' THEN importo END),2) AS importo_entrata,
round(sum(CASE WHEN segno = '-' THEN importo END),2) AS importo_uscita

FROM banca.cliente clt
inner join banca.conto cnt ON clt.id_cliente = cnt.id_cliente
inner join banca.transazioni trn ON cnt.id_conto = trn.id_conto
inner join banca.tipo_transazione ttrn ON trn.id_tipo_trans = ttrn.id_tipo_transazione

GROUP BY clt.id_cliente 
ORDER BY clt.id_cliente;

    
    
/*
    
    -- Total number of accounts held
    -- Number of accounts held by type (one indicator per type)
    ---------------------------------------------------------------------------------
*/

CREATE TEMPORARY TABLE banca.tot_cont AS
SELECT
clt.id_cliente,
count(DISTINCT cnt.id_conto) conti_posseduti,
count(DISTINCT CASE WHEN cnt.id_tipo_conto = '0' THEN trn.id_conto END) conto_base,
count(DISTINCT CASE WHEN cnt.id_tipo_conto = '1' THEN trn.id_conto END) conto_business,
count(DISTINCT CASE WHEN cnt.id_tipo_conto= '2' THEN trn.id_conto END) conto_privati,
count(DISTINCT CASE WHEN cnt.id_tipo_conto= '3' THEN trn.id_conto END) conto_famiglie

FROM banca.cliente clt
inner join banca.conto cnt ON clt.id_cliente = cnt.id_cliente
inner join banca.transazioni trn ON cnt.id_conto = trn.id_conto

GROUP BY clt.id_cliente 
ORDER BY clt.id_cliente;


/*

    -- Number of outgoing transactions by type (one indicator per type)
    -- Number of incoming transactions by type (one indicator per type)
	---------------------------------------------------------------------------------
    
*/

CREATE TEMPORARY TABLE banca.trans_tipo_ AS
SELECT
clt.id_cliente,

count(CASE WHEN trn.id_tipo_trans = '0' THEN trn.id_conto END) entrata_stipendio,
count(CASE WHEN trn.id_tipo_trans = '1' THEN trn.id_conto  END) entrata_pensione,
count(CASE WHEN trn.id_tipo_trans = '2' THEN trn.id_conto  END) entrata_dividendi,
count(CASE WHEN trn.id_tipo_trans = '3' THEN trn.id_conto  END) uscita_acq_amazon,
count(CASE WHEN trn.id_tipo_trans = '4' THEN trn.id_conto  END) uscita_rata_mutuo,
count(CASE WHEN trn.id_tipo_trans= '5' THEN trn.id_conto  END) uscita_hotel,
count(CASE WHEN trn.id_tipo_trans= '6' THEN trn.id_conto  END) uscita_aereo,
count(CASE WHEN trn.id_tipo_trans= '7' THEN trn.id_conto  END) uscita_supermercato

FROM banca.cliente clt
inner join banca.conto cnt ON clt.id_cliente = cnt.id_cliente
inner join banca.transazioni trn ON cnt.id_conto = trn.id_conto

GROUP BY clt.id_cliente 
ORDER BY clt.id_cliente;


/*
      
       -- Outgoing transaction amount by account type (one indicator per type)
       -- Incoming transaction amount by account type (one indicator per type)
		---------------------------------------------------------------------------------
       
*/

CREATE TEMPORARY TABLE banca.importo_tipo_cnt AS
SELECT
clt.id_cliente,
round(sum(CASE WHEN segno = '-' AND cnt.id_tipo_conto = '0' THEN importo ELSE 0 END),2) uscita_conto_base,
round(sum(CASE WHEN segno = '-' AND cnt.id_tipo_conto = '1' THEN importo ELSE 0 END),2) uscita_conto_business,
round(sum(CASE WHEN segno = '-' AND cnt.id_tipo_conto = '2' THEN importo ELSE 0 END),2) uscita_conto_privati,
round(sum(CASE WHEN segno = '-' AND cnt.id_tipo_conto = '3' THEN importo ELSE 0 END),2) uscita_conto_famiglie,

round(sum(CASE WHEN segno = '+' AND cnt.id_tipo_conto = '0' THEN importo ELSE 0 END),2) entrata_conto_base,
round(sum(CASE WHEN segno = '+' AND cnt.id_tipo_conto = '1' THEN importo ELSE 0 END),2) entrata_conto_business,
round(sum(CASE WHEN segno = '+' AND cnt.id_tipo_conto = '2' THEN importo ELSE 0 END),2) entrata_conto_privati,
round(sum(CASE WHEN segno = '+' AND cnt.id_tipo_conto = '3' THEN importo ELSE 0 END),2) entrata_conto_famiglie

FROM banca.cliente clt
inner join banca.conto cnt ON clt.id_cliente = cnt.id_cliente
inner join banca.transazioni trn ON cnt.id_conto = trn.id_conto
inner join banca.tipo_conto tcnt ON cnt.id_tipo_conto = tcnt.id_tipo_conto
inner join banca.tipo_transazione ttrn ON trn.id_tipo_trans = ttrn.id_tipo_transazione

GROUP BY clt.id_cliente 
ORDER BY clt.id_cliente;


/*

    Finally I create a denormalized table that contains behavioral indicators on the customer, 
    calculated on the basis of transactions and product ownership.
	---------------------------------------------------------------------------------
    
*/


CREATE TEMPORARY TABLE analisi_finale AS
SELECT 
    eta.id_cliente,
    eta.eta,
    trans.transazioni_uscita,
    trans.transazioni_entrata,
    trans.importo_uscita,
    trans.importo_entrata,
    tot_cont.conti_posseduti,
    tot_cont.conto_base,
    tot_cont.conto_business,
    tot_cont.conto_privati,
    tot_cont.conto_famiglie,
    trans_tipo_.entrata_stipendio,
    trans_tipo_.entrata_pensione,
    trans_tipo_.entrata_dividendi,
    trans_tipo_.uscita_acq_amazon,
    trans_tipo_.uscita_rata_mutuo,
    trans_tipo_.uscita_hotel,
    trans_tipo_.uscita_aereo,
    trans_tipo_.uscita_supermercato,
    importo_tipo_cnt.uscita_conto_base,
    importo_tipo_cnt.uscita_conto_business,
    importo_tipo_cnt.uscita_conto_privati,
    importo_tipo_cnt.uscita_conto_famiglie,
    importo_tipo_cnt.entrata_conto_base,
    importo_tipo_cnt.entrata_conto_business,
    importo_tipo_cnt.entrata_conto_privati,
    importo_tipo_cnt.entrata_conto_famiglie
    
FROM banca.eta
left join banca.trans ON eta.id_cliente = trans.id_cliente
left join banca.tot_cont ON eta.id_cliente = tot_cont.id_cliente
left join banca.trans_tipo_ ON eta.id_cliente = trans_tipo_.id_cliente
left join banca.importo_tipo_cnt ON eta.id_cliente = importo_tipo_cnt.id_cliente;

SELECT * FROM banca.analisi_finale;