defmodule KVServer.CommandTest do
  use ExUnit.Case, async: true

  doctest KVServer.Command

  setup context do
    {:ok, _} = KV.Registry.start_link(context.test)
    {:ok, registry: context.test}
  end

  test "run creates new buckets", %{registry: registry} do
    assert {:error, :not_found} = KVServer.Command.run({:put, "shopping", "eggs", 12}, registry)

    assert {:ok, "OK\r\n"} = KVServer.Command.run({:create, "shopping"}, registry)
    assert {:ok, "OK\r\n"} = KVServer.Command.run({:put, "shopping", "eggs", 12}, registry)
  end

  test "run adds and retrieves values from buckets", %{registry: registry} do
    KVServer.Command.run({:create, "shopping"}, registry)

    assert {:ok, "OK\r\n"} = KVServer.Command.run({:put, "shopping", "eggs", 12}, registry)

    assert {:ok, "12\r\nOK\r\n"} = KVServer.Command.run({:get, "shopping", "eggs"}, registry)
  end

  test "run deletes values from buckets", %{registry: registry} do
    KVServer.Command.run({:create, "shopping"}, registry)
    KVServer.Command.run({:put, "shopping", "eggs", 12}, registry)
    assert {:ok, "12\r\nOK\r\n"} = KVServer.Command.run({:get, "shopping", "eggs"}, registry)

    assert {:ok, "OK\r\n"} = KVServer.Command.run({:delete, "shopping", "eggs"}, registry)
    assert {:error, :not_found} = KVServer.Command.run({:get, "shopping", "eggs"}, registry)
  end

  test "run returns not found when performing actions on unknown keys or buckets", %{registry: registry} do
    KVServer.Command.run({:create, "shopping"}, registry)

    assert {:error, :not_found} = KVServer.Command.run({:delete, "shopping", "eggs"}, registry)
    assert {:error, :not_found} = KVServer.Command.run({:put, "chores", "sweep", 1}, registry)
    assert {:error, :not_found} = KVServer.Command.run({:get, "shopping", "bananas"}, registry)
  end
end
