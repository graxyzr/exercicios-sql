drop table pizzasabor;
drop table pizza;
drop table comanda;
drop table precotamanho;
drop table saboringrediente;
drop table sabor;
drop table mesa;
drop table borda;
drop table tamanho;
drop table tipo;
drop table ingrediente;

create table ingrediente (
    codigo integer check (codigo >= 0),
    nome varchar(100) not null check (length(trim(nome)) >= 5),
    primary key (codigo)
);

create table tipo (
    codigo integer check (codigo >= 0),
    nome varchar(100) not null check (length(trim(nome)) >= 5),
    primary key (codigo)
);


create table tamanho (
    codigo char(1),
    nome varchar(100) not null check (length(trim(nome)) >= 5),
    qtdesabores integer not null check (qtdesabores > 0),
    primary key (codigo)
);

create table borda (
    codigo integer check (codigo >= 0),
    nome varchar(100) not null check (length(trim(nome)) >= 5),
    preco real not null check (preco >= 0),
    primary key (codigo)
);

create table mesa (
    codigo integer check (codigo >= 0),
    nome varchar(100) not null check (length(trim(nome)) >= 5),
    primary key (codigo)
);

create table sabor (
    codigo integer check (codigo > 0),
    nome varchar(100) not null check (length(trim(nome)) >= 5),
    tipo integer not null,
    primary key (codigo),
    foreign key (tipo) references tipo(codigo)
);

create table saboringrediente (
    sabor integer,
    ingrediente integer,
    foreign key (sabor) references sabor(codigo),
    foreign key (ingrediente) references ingrediente(codigo),
    primary key (sabor, ingrediente)
);

create table precotamanho (
    tipo integer not null,
    tamanho char(1) not null,
    preco real not null check (preco >= 0),
    foreign key (tipo) references tipo(codigo),
    foreign key (tamanho) references tamanho(codigo),
    primary key (tipo, tamanho)
);

create table comanda (
    numero integer check (numero > 0),
    data date default current_date check (data >= current_date),
    mesa integer not null,
    pago boolean default false, 
    primary key (numero),
    foreign key (mesa) references mesa(codigo)
);

create table pizza (
    codigo integer check (codigo > 0),
    comanda integer not null,
    tamanho char(1) not null,
    borda integer,
    primary key (codigo),
    foreign key (comanda) references comanda(numero),
    foreign key (tamanho) references tamanho(codigo),
    foreign key (borda) references borda(codigo)
);

create table pizzasabor (
    pizza integer not null,
    sabor integer not null,
    primary key (pizza, sabor),
    foreign key (pizza) references pizza(codigo),
    foreign key (sabor) references sabor(codigo)
);