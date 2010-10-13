package org.tbyrne.actLibrary.display.visualSockets.mappers
{
	import org.tbyrne.instanceFactory.IInstanceFactory;
	import org.tbyrne.actLibrary.display.visualSockets.plugs.IPlugDisplay;

	public class DataTypePlugMapper extends AbstractPlugMapper
	{
		
		[Property(clonable="true")]
		public var dataType: Class;
		
		[Property(clonable="true")]
		public var displayFactory:IInstanceFactory;
		
		[Property(clonable="true")]
		public var forceRefresh:Boolean;
		
		public function DataTypePlugMapper(dataType: Class=null, displayFactory:IInstanceFactory=null)
		{
			this.dataType = dataType;
			this.displayFactory = displayFactory;
		}
		
		override public function shouldRespond(dataProvider: *, currentDisplay: IPlugDisplay): Boolean{
			return dataProvider is dataType;
		}
		override public function shouldRefresh(dataProvider: *, currentDisplay: IPlugDisplay): Boolean{
			return this.forceRefresh || !(displayFactory.matchesType(currentDisplay));
		}
		override public function createInstance(dataProvider: *, currentDisplay: IPlugDisplay): IPlugDisplay{
			return displayFactory.createInstance() as IPlugDisplay;
		}
		override public function initInstance(dataProvider: *, currentDisplay: IPlugDisplay): void{
			displayFactory.initialiseInstance(currentDisplay);
		}
	}
}