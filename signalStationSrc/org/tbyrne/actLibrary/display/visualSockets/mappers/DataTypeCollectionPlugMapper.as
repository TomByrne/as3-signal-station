package org.tbyrne.actLibrary.display.visualSockets.mappers
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.factories.IInstanceFactory;
	import org.tbyrne.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	
	public class DataTypeCollectionPlugMapper extends DataTypePlugMapper
	{
		public function DataTypeCollectionPlugMapper(dataType:Class=null, displayFactory:IInstanceFactory=null){
			super(dataType, displayFactory);
		}
		override public function shouldRespond(dataProvider: *, currentDisplay: IPlugDisplay): Boolean{
			var array:Array = (dataProvider as Array);
			if(array!=null){
				if(array.length>0){
					return super.shouldRespond(array[0],currentDisplay);
				}
			}else{
				var dict:Dictionary = (dataProvider as Dictionary);
				if(dict!=null){
					for each(var obj:Object in dict){
						return super.shouldRespond(obj,currentDisplay);
					}
				}
			}
			return false;
		}
	}
}