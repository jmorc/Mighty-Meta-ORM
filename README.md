# Mighty Meta ORM

This project explores the us of meta-programming to create an object-relational mapping (ORM) system. 

## Some of the key features include:

* Associations

## Project details:

* The 'SQLObject' class

This class allows the creation of objects representing SQL data. It resembles the 'ActiveRecord::Base' class, used in as the parent class for models in a Rails app.  Features of the 'SQLObject' include:

* '::all' Returns an array of objects representing each item in the database.  
* '::find' Finds a row of data by id number and returns an object representing the entry.
* '#insert' Add a new entry to the database from an instance of 'SQLObject'.
* '#update' Updates a row of data with changes made on the corresponding 'SQLOjbect'.
* '#save' Saves an entry to the database by calling '#insert' if it is a new row of data or '#update' if an existing row is being modified.
    
