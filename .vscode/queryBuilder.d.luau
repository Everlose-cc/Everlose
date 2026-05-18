export type QueryBuilder = {
	_ClassName: string?,
	_Name: string?,
	_Tags: { string },
	_Properties: { [string]: any },
	_Attributes: { [string]: any },
	_Pseudos: { string },
	_Combinator: { Type: string, Query: QueryBuilder }?,
	_Alternatives: { QueryBuilder },
	
	SetClass: (self: QueryBuilder, className: string) -> QueryBuilder,
	SetName: (self: QueryBuilder, name: string) -> QueryBuilder,
	AddTag: (self: QueryBuilder, tag: string) -> QueryBuilder,
	
	SetProperties: (self: QueryBuilder, props: { [string]: any }) -> QueryBuilder,
	SetAttributes: (self: QueryBuilder, attrs: { [string]: any }) -> QueryBuilder,
	SetProperty: (self: QueryBuilder, key: string, value: any) -> QueryBuilder,
	SetAttribute: (self: QueryBuilder, key: string, value: any) -> QueryBuilder,
	
	Child: (self: QueryBuilder, subQuery: QueryBuilder) -> QueryBuilder,
	Descendant: (self: QueryBuilder, subQuery: QueryBuilder) -> QueryBuilder,
	
	Not: (self: QueryBuilder, ...QueryBuilder) -> QueryBuilder,
	Has: (self: QueryBuilder, ...QueryBuilder) -> QueryBuilder,
	
	Or: (self: QueryBuilder, ...QueryBuilder) -> QueryBuilder,
	Also: (self: QueryBuilder, ...QueryBuilder) -> QueryBuilder,
	
	ToQuery: (self: QueryBuilder) -> string,
}
