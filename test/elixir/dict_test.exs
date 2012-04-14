Code.require_file "../test_helper", __FILE__

defmodule DictTest.Common do
  defmacro __using__(module, _opts // []) do
    quote do
      use ExUnit.Case

      test :new_pair do
        dict = new_dict {"a", 0}
        assert_equal 1, PDict.size dict

        assert PDict.has_key? dict, "a"
        assert_equal 0, PDict.get dict, "a"
      end

      test :new_pairs do
        dict = new_dict [{"first key", 1}, {"second key", 2}]
        assert_equal 2, PDict.size dict

        assert_equal ["first key", "second key"], List.sort PDict.keys dict
        assert_equal [1, 2], List.sort PDict.values dict
      end

      test :new_two_lists do
        dict = new_dict ["first key", "second key"], [1, 2]
        assert_equal 2, PDict.size dict
        assert_equal 1, PDict.get dict, "first key"
        assert_equal 2, PDict.get dict, "second key"

        assert_raises ArgumentError, fn() -> new_dict(["first key"], [1, 2]) end
      end

      test :new_pairs_with_transform do
        dict = new_dict [{1}, {2}, {3}], fn({x}) -> { {x}, x } end
        assert_equal 3, PDict.size dict

        assert_equal [{1}, {2}, {3}], List.sort PDict.keys dict
        assert_equal [1, 2, 3], List.sort PDict.values dict
      end

      test :get do
        assert_equal 1, PDict.get(new_dict, "first_key")
        assert_equal 2, PDict.get(new_dict, "second_key")
        assert_equal nil, PDict.get(new_dict, "other_key")
        assert_equal "default", PDict.get(empty_dict, "first_key", "default")
      end

      test :put do
        dict = PDict.put(empty_dict, {"first_key", 1})
        assert_equal 1, PDict.get dict, "first_key"

        dict = PDict.put(new_dict, "first_key", {1})
        assert_equal {1}, PDict.get dict, "first_key"
        assert_equal 2, PDict.get dict, "second_key"
      end

      test :keys do
        assert_equal ["first_key", "second_key"], List.sort PDict.keys new_dict
        assert_equal [], PDict.keys empty_dict
      end

      test :values do
        assert_equal [1, 2], List.sort PDict.values(new_dict)
        assert_equal [], PDict.values empty_dict
      end

      test :delete do
        mdict = PDict.delete new_dict, "second_key"
        assert_equal 1, PDict.size mdict
        assert PDict.has_key? mdict, "first_key"
        refute PDict.has_key? mdict, "second_key"

        mdict = PDict.delete(new_dict, "other_key")
        assert_equal mdict, new_dict
        assert_equal 0, PDict.size PDict.delete(empty_dict, "other_key")
      end

      test :merge do
        dict = new_dict
        assert_equal dict, PDict.merge empty_dict, dict
        assert_equal dict, PDict.merge dict, empty_dict
        assert_equal dict, PDict.merge dict, dict
        assert_equal empty_dict, PDict.merge empty_dict, empty_dict

        dict1 = new_dict ["a", "b", "c"], [1, 2, 3]
        dict2 = new_dict ["a", "c", "d"], [3, :a, 0]
        assert_equal new_dict(["a", "b", "c", "d"], [3, 2, :a, 0]), PDict.merge(dict1, dict2)
      end

      test :merge_with_function do
        dict1 = new_dict ["a", "b"], [1, 2]
        dict2 = new_dict ["a", "d"], [3, 4]
        result = PDict.merge dict1, dict2, fn(_k, v1, v2) ->
          v1 + v2
        end
        assert_equal new_dict(["a", "b", "d"], [4, 2, 4]), result
      end

      test :has_key do
        dict = new_dict [{"a", 1}]
        assert PDict.has_key?(dict, "a")
        refute PDict.has_key?(dict, "b")
      end

      test :size do
        assert_equal 2, PDict.size new_dict
        assert_equal 0, PDict.size empty_dict
      end

      test :update do
        dict = PDict.update new_dict, "first_key", fn(val) -> -val end
        assert_equal -1, PDict.get dict, "first_key"

        dict = PDict.update dict, "non-existent", "...", fn(val) -> -val end
        assert_equal "...", PDict.get dict, "non-existent"
      end

      test :empty do
        assert_equal empty_dict, PDict.empty new_dict
      end

      defp empty_dict, do: unquote(module).new
      defp new_dict({k, v}), do: unquote(module).new {k, v}
      defp new_dict(list // [{"first_key", 1}, {"second_key", 2}]), do: unquote(module).new list
      defp new_dict(list, transform) when is_function(transform), do: unquote(module).new list, transform
      defp new_dict(keys, values), do: unquote(module).new keys, values
    end
  end
end

defmodule DictTest do
  require DictTest.Common
  DictTest.Common.__using__(Dict)

  test :new do
    assert_equal :dict.new, Dict.new
  end
end

defmodule OrddictTest do
  require DictTest.Common
  DictTest.Common.__using__(Orddict)

  test :new do
    assert_equal [], Orddict.new
  end
end
