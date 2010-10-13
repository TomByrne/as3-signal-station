package org.tbyrne.collections
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.hoborg.Cloner;
	
	public class DictionaryUtils
	{
		public static function clear(dictionary: Dictionary): void
		{
			for (var key: * in dictionary)
			{
				delete dictionary[key];
			} 
		}
		
		public static function merge(primary: Dictionary, secondary: Dictionary, 
			returnNew: Boolean = true): Dictionary
		{
			var resultDict: Dictionary = null;
			if (returnNew)
			{
				resultDict = Cloner.clone(primary);
			}
			else
			{
				resultDict = primary;
			}
			
			for (var key: * in secondary)
			{
				if (!(key in resultDict))
				{
					resultDict[key] = secondary[key];
				}
			}
			return resultDict;
		}
		
		public static function getItemCaseInsensitive(key: String, dictionary: Dictionary): *
		{
			var item: * = null;
			for (var testKey: String in dictionary)
			{
				if (testKey.toLowerCase() == key.toLowerCase())
				{
					item = dictionary[testKey];
					break;
				}
			}
			return item;
		}
		
		public static function getLength(dictionary: Dictionary): uint
		{
			var length: uint = 0;
			for (var key: * in dictionary)
			{
				length++;
			}
			return length;
		}
		
		public static function getKeyByItem(dictionary: Dictionary, item: *): *
		{
			var targetKey: * = null;
			for (var key: * in dictionary)
			{
				if (dictionary[key] == item)
				{
					targetKey = key;
					break;
				}
			}
			return targetKey;
		}
		
		public static function hasItem(dictionary: Dictionary): Boolean
		{
			return DictionaryUtils.getLength(dictionary) > 0;
		}
		
		public static function getKeys(dictionary: Dictionary): Array
		{
			var keys: Array = new Array();
			for (var key: * in dictionary)
			{
				keys.push(key);
			}
			return keys;
		}
		
		public static function getValues(dictionary: Dictionary): Array
		{
			var values: Array = new Array();
			for each (var value: * in dictionary)
			{
				values.push(value);
			}
			return values;
		}
		
		public static function toString(dictionary: Dictionary): String
		{
			var desc: String = "[Dictionary";
			for (var i: * in dictionary)
			{
				desc += " " + i + ":" + dictionary[i];
			}
			desc += "]";
			return desc;
		}
	}
}