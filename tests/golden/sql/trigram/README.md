A trigram index.  Under postgres it comes out `USING gist` with
`gist_trgm_ops`; under sqlite the schema printer itself reports that the
database cannot do it, and that diagnostic is the golden — no file is
written then.  (The driver used to write the schema anyway, index and all,
alongside the error.)
