--/*
\connect sduser_db
\set ON_ERROR_STOP on
drop table if exists tlanguage cascade;
drop table if exists tsense cascade;
drop type if exists senseforkstatus cascade;
--*/ 

create table tlanguage (
  id serial primary KEY,
  parentid int references tlanguage,
  slug varchar(128) not null unique,
  commentary text);

comment on table tlanguage is 'tlanguage is a language or a dialect, or a source of translation';
comment on column tlanguage.slug is 'slug is an identifier in the parent''s space. Access item by parentslug/childslug';

insert into tlanguage (id, slug) 
  values (1,'русский'), (2,'english'), (3,'中文');


insert into tlanguage (id, parentid, slug, commentary) 
  values (4, 1, '1С', '1С предприятие')
    ,(5, 1, 'excel', 'Microsoft Excel');

create or replace function get_language_slug(p_languageid int) returns text
 language plpgsql strict as $$
 declare v_result text;
 declare v_len_limit int;
  begin
  
  v_len_limit = 256;
  with recursive r as 
  (select id, parentid, cast(slug as text) from tlanguage
  where id = p_languageid 
  union 
  select r.id, tl.parentid, r.slug || '/' || tl.slug from r 
  left join tlanguage tl on tl.id = r.parentid 
  where tl.id is not null 
    or r.slug is null -- this should never happen as slug is not null, but just in case
    or length(r.slug) > v_len_limit -- guard against an unlimited recursion 
  )

  select slug from r 
  where parentid is null 
  into v_result;

  if length(v_result) > v_len_limit then
    v_result = 'bad slug for languageid='||p_languageid;
  end if;

  return v_result;
  end;
$$;


create table tsense (
  id serial primary KEY,
  languageid int not null references tlanguage,
  phrase text not null,
  word varchar(512) not null,
  deleted bool not null default false,
  originid bigint references tsense, 
  ownerid bigint references sduser
);

comment on table tsense is 'tsense stored a record for a specific sense of a word. 
There can be multiple records for the same word. API path is based on the id, like русский/excel/1';
comment on column tsense.phrase is 'Phrase in the dialect that describes the sense of the word';
comment on column tsense.word is 'Word or word combination in the dialect denoting the sense';
comment on column tsense.deleted is 'We can''t delete records due to versioning, so we mark them deleted';
comment on column tsense.originid is 'Non-empty originid means that this is a verion. In this case, ownerid must be non-null';
comment on column tsense.ownerid is 'In case of forked sense, owner of a fork';

insert into tsense (languageid, phrase, word)
  VALUES
  (2,'Programming language by Google created in 2000s','golang');

insert into tsense (languageid, phrase, word)
  VALUES
  (2,'Programming language by Google created in 2000s','go');

insert into tsense (languageid, phrase, word)
  VALUES
  (1,'Язык программирования, созданный google в 2000-х годах','golang');

insert into tsense (languageid, phrase, word)
  VALUES
  (1,'Язык программирования, созданный google в 2000-х годах','go');

-- create type senseforkstatus AS ENUM ('single', 'has proposals', 'a proposal');




\echo *** language_and_sense_tbl.sql Done