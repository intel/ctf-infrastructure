#!/usr/bin/env python3

import datetime
import argparse
from sqlalchemy import Column, Integer, String, DateTime, MetaData, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy_utils import database_exists

Base = declarative_base()

class VmList(Base):
    __tablename__ = 'vmList'
    vmName = Column(String, unique=True, primary_key=True)
    lastRefresh = Column(DateTime)
    rebootable  = Column(Boolean)

def addToDB(vmToAdd, rebootable, DB_URI):
    engine = create_engine(DB_URI)
    meta = MetaData(engine, reflect=True)
    vmListing = meta.tables['vmList']
    conn = engine.connect()

    conn.execute(vmListing.insert(),[
    {'vmName':vmToAdd,
     'lastRefresh': datetime.datetime.now(),
     'rebootable':rebootable
    }])

def deleteFromDB(vmToDelete, DB_URI):
    engine = create_engine(DB_URI)
    meta = MetaData(engine, reflect=True)
    vmListing = meta.tables['vmList']
    conn = engine.connect()
 
    conn.execute(vmListing.delete().where(
        vmListing.c.vmName == vmToDelete))

if __name__ == "__main__":
    from sqlalchemy import create_engine
    from settings import DB_URI
    if database_exists(DB_URI):
        parser = argparse.ArgumentParser(description="Updating vmList DB")
        parser.add_argument('-a', '--add')
        parser.add_argument('-d', '--delete')
        parser.add_argument('-r', '--rebootable', action='store_true', default=False)
        args = parser.parse_args()

        if args.add and args.delete:
            raise SystemExit("You can only perform one action at once")
        elif args.add: 
            addToDB(args.add, args.rebootable, DB_URI)
        elif args.delete:
            deleteFromDB(args.delete, DB_URI)
    
    else:
        engine = create_engine(DB_URI)
        Base.metadata.create_all(engine)
        try:    
            for vm in open('vmsInRotation', 'r').readlines():
                vmName = vm.split(':')[0].rstrip('\n')
                rebootable = vm.split(':')[1].rstrip('\n')
                print (vmName)
                print (rebootable)
                addToDB(vmName, rebootable, DB_URI)
        except:
            pass
