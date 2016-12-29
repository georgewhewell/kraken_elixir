defmodule Kraken.Api do

  def asset_pairs do
    get_from_api "/0/public/AssetPairs"
  end

  def orderbook(pair) do
    get_from_api "/0/public/Depth?pair=#{pair}"
  end

  def ticker(pair) do
    get_from_api "/0/public/Ticker?pair=#{pair}"
  end

  def balance do
    post_to_api "/0/private/Balance"
  end

  def trade_balance do
    post_to_api "/0/private/TradeBalance"
  end

  def deposit_status(opts) do
    asset = Keyword.fetch!(opts, :asset)
    post_to_api "/0/private/DepositStatus", %{asset: asset}
  end

  def open_orders(opts \\ []) do
    trades = Keyword.get(opts, :trades)
    userref = Keyword.get(opts, :userref)
    post_to_api "/0/private/OpenOrders", reduce_params(%{trades: trades, userref: userref})
  end

  def query_orders(txid, opts \\ []) do
    trades = Keyword.get(opts, :trades)
    userref = Keyword.get(opts, :userref)
    post_to_api "/0/private/QueryOrders", reduce_params(%{txid: txid, trades: trades, userref: userref})
  end

  def trade_volume(opts \\ []) do
    pair = Keyword.get(opts, :pair)
    post_to_api "/0/private/TradeVolume", reduce_params(%{pair: pair})
  end

  def buy(opts \\ []) do
    add_order("buy", opts)
  end

  def sell(opts \\ []) do
    add_order("sell", opts)
  end

  def cancel_order(txid) do
    post_to_api "/0/private/CancelOrder", %{txid: txid}
  end

  def withdraw(opts) do
    asset = Keyword.fetch!(opts, :asset)
    key = Keyword.fetch!(opts, :key)
    amount = Keyword.fetch!(opts, :amount)
    post_to_api "/0/private/Withdraw", %{asset: asset, key: key, amount: amount}
  end

  defp add_order(type, opts) do
    pair = Keyword.fetch!(opts, :pair)
    ordertype = Keyword.fetch!(opts, :ordertype)
    volume = Keyword.fetch!(opts, :volume)
    price = Keyword.get(opts, :price)
    userref = Keyword.get(opts, :userref)
    validate = Keyword.get(opts, :validate)
    post_to_api "/0/private/AddOrder", reduce_params(%{userref: userref, validate: validate, pair: pair, type: type, ordertype: ordertype, volume: volume, price: price})
  end

  defp get_from_api(path) do
    Kraken.Api.Transport.get(path)
  end

  defp post_to_api(method, params \\ %{}) do
    Kraken.Api.Transport.post(method, params)
  end

  defp reduce_params(params_map) do
    for {k, v} <- params_map, v != nil, into: %{}, do: {k, v}
  end

end
