# Represents an item that can be bought in the shop
class_name BuyableResource extends Resource

@export var name: String
@export var cost: int
@export var currency: Currency

enum Currency {
	Cash,
	Diamonds
}

func _init(p_name = "", p_cost = 0, p_currency = Currency.Cash):
	name = p_name
	cost = p_cost
	currency = p_currency
