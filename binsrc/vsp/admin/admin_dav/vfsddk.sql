--
--  vfsddk.sql
--
--  $Id$
--
--  Site-copy robot DB.
--  
--  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
--  project.
--  
--  Copyright (C) 1998-2006 OpenLink Software
--  
--  This project is free software; you can redistribute it and/or modify it
--  under the terms of the GNU General Public License as published by the
--  Free Software Foundation; only version 2 of the License, dated June 1991.
--  
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--  
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
--  
--  

use WS
;

-- Copied sites
create table WS.WS.VFS_URL (
    VU_HOST 	varchar,
    VU_URL 	varchar,
    VU_ROOT 	varchar,
    VU_CHKSUM	varchar,
    VU_ETAG	varchar,
    VU_CPTIME	datetime,
    VU_OTHER	varchar,
    primary key (VU_HOST, VU_URL, VU_ROOT))
create index VU_HOST_ROOT on WS.WS.VFS_URL (VU_HOST, VU_ROOT)
;


-- Copy queue
create table WS.WS.VFS_QUEUE (
    VQ_HOST 	varchar,
    VQ_TS 	datetime,
    VQ_URL 	varchar,
    VQ_ROOT 	varchar,
    VQ_STAT	varchar (15),
    VQ_OTHER	varchar,
    primary key (VQ_HOST, VQ_URL, VQ_ROOT))
create index VQ_HOST_ROOT_STAT on WS.WS.VFS_QUEUE (VQ_HOST, VQ_ROOT, VQ_STAT)
create index VQ_HOST_ROOT on WS.WS.VFS_QUEUE (VQ_HOST, VQ_ROOT)
create index VQ_HOST_TIME on WS.WS.VFS_QUEUE (VQ_HOST, VQ_ROOT, VQ_TS)
create index VQ_TS on WS.WS.VFS_QUEUE (VQ_TS)
;


-- Site setting
create table WS.WS.VFS_SITE (
    VS_DESCR	varchar,
    VS_HOST 	varchar,
    VS_URL	varchar,
    VS_INX	varchar (5),
    VS_OWN	integer,
    VS_ROOT	varchar,   -- target collection
    VS_NEWER	datetime,
    VS_DEL	varchar,
    VS_FOLLOW	varchar,
    VS_NFOLLOW	varchar,
    VS_SRC	varchar,  -- do get on images
    VS_OPTIONS  varchar,
    VS_METHOD   varchar,
    VS_OTHER	varchar,
    VS_OPAGE	varchar,
    VS_REDIRECT int default 1,
    VS_STORE 	int default 1,
    VS_UDATA	long varbinary,
    VS_DLOAD_META int default 0,
    primary key (VS_HOST, VS_ROOT))
create index VS_HOST_ROOT on WS.WS.VFS_SITE (VS_HOST, VS_URL, VS_ROOT)
;

create table WS.WS.VFS_SITE_RDF_MAP (
    VM_ID   integer identity,
    VM_HOST varchar,
    VM_ROOT varchar,
    VM_RDF_MAP int,	-- ref to SYS_RDF_MAPPERS table
    VM_SEQ  integer identity,
    primary key (VM_HOST, VM_ROOT, VM_RDF_MAP, VM_SEQ))
;

create procedure WS.WS.VFS_TBL_UPGRADE ()
{
  declare _err, _state varchar;
  _state := null;
  exec ('select VS_OPAGE from WS.WS.VFS_SITE', _state, _err);
  if (_state is not null)
    DB.DBA.execstr ('alter table WS.WS.VFS_SITE add VS_OPAGE varchar');
  _state := null;
  exec ('select VS_OTHER from WS.WS.VFS_SITE', _state, _err);
  if (_state is not null)
    DB.DBA.execstr ('alter table WS.WS.VFS_SITE add VS_OTHER char (10)');
  _state := null;
  exec ('select VQ_OTHER from WS.WS.VFS_QUEUE', _state, _err);
  if (_state is not null)
    DB.DBA.execstr ('alter table WS.WS.VFS_QUEUE add VQ_OTHER varchar');
  _state := null;
  exec ('select VU_OTHER from WS.WS.VFS_URL', _state, _err);
  if (_state is not null)
    DB.DBA.execstr ('alter table WS.WS.VFS_URL add VU_OTHER varchar');
  _state := null;
  exec ('select VS_REDIRECT from WS.WS.VFS_SITE', _state, _err);
  if (_state is not null)
    {
      DB.DBA.execstr ('alter table WS.WS.VFS_SITE add VS_REDIRECT int default 1');
      DB.DBA.execstr ('alter table WS.WS.VFS_SITE add VS_STORE int default 1');
      DB.DBA.execstr ('alter table WS.WS.VFS_SITE add VS_UDATA long varbinary');
    }
}
;

--!AFTER
WS.WS.VFS_TBL_UPGRADE ()
;

--!AFTER
alter table WS.WS.VFS_SITE add VS_DLOAD_META int default 0
;

