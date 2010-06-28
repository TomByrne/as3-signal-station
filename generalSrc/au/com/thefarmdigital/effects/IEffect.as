package au.com.thefarmdigital.effects
{
	import org.farmcode.display.assets.IDisplayAsset;
	
	public interface IEffect
	{
		function set subject(value:IDisplayAsset):void;
		function get subject():IDisplayAsset;
		
		function render():void;
		function remove():void;
	}
}