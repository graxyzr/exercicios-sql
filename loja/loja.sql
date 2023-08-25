drop table item;
drop table pedido;
drop table produto;
drop table cliente;
drop table vendedor;

create table vendedor (
    codigo integer check (codigo >= 0),
    nome varchar(100) not null check (length(trim(nome)) >= 5),
    primary key (codigo)
);

create table cliente (
    codigo integer check (codigo >= 0),
    nome varchar(100) not null check (length(trim(nome)) >= 5),
    endereco varchar(100) not null,
    cidade varchar(100) not null,
    uf char(2) not null,
    cep char(9) not null check (length(trim(cep)) = 9),
    primary key (codigo)
);

create table produto (
    codigo integer check (codigo >= 0),
    descricao varchar(1500) not null,
    preco real not null check (preco >= 0),
    comissao real not null check (comissao >= 0),
    primary key (codigo)
);

create table pedido (
    codigo integer check (codigo >= 0),
    cliente not null,
    vendedor not null,
    data date default current_date check (data >= current_date),
    primary key (codigo),
    foreign key (cliente) references cliente(codigo),
    foreign key (vendedor) references vendedor(codigo)
);

create table item (
    pedido not null,
    produto not null,
    quantidade integer default (0),
    primary key (pedido, produto),
    foreign key (pedido) references pedido(codigo),
    foreign key (produto) references produto(codigo)
);