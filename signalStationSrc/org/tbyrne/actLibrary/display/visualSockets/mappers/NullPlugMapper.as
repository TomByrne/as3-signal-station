package org.tbyrne.actLibrary.display.visualSockets.mappers
{
	import org.tbyrne.factories.IInstanceFactory;
	import org.tbyrne.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	
	public class NullPlugMapper extends AbstractPlugMapper
	{
		[Property(clonable="true")]
		public var displayFactory:IInstanceFactory;
		
		[Property(clonable="true")]
		public var forceRefresh:Boolean;
		
		public function NullPlugMapper(displayFactory:IInstanceFactory=null)
		{
			this.displayFactory = displayFactory;
		}
		
		override public function shouldRespond(dataProvider: *, currentDisplay: IPlugDisplay): Boolean{
			return dataProvider==null;
		}
		override public function shouldRefresh(dataProvider: *, currentDisplay: IPlugDisplay): Boolean{
			return this.forceRefresh || !(displayFactory.matchesType(currentDisplay));
		}
		override public function createInstance(dataProvider: *, currentDisplay: IPlugDisplay): IPlugDisplay{
			return displayFactory.createInstance() as IPlugDisplay;
		}
	}
}