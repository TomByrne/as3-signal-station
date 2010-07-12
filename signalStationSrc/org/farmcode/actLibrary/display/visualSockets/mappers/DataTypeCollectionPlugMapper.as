package org.farmcode.actLibrary.display.visualSockets.mappers
{
	import flash.utils.Dictionary;
	
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	
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