package org.tbyrne.composeLibrary.away3d.traits
{
	import away3d.materials.methods.ShadingMethodBase;
	
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.away3d.types.IShadowMethodTrait;
	
	public class ShadowMethodTrait extends AbstractTrait implements IShadowMethodTrait
	{
		
		public function get shadowMethod():ShadingMethodBase{
			return _shadowMethod;
		}
		public function set shadowMethod(value:ShadingMethodBase):void{
			_shadowMethod = value;
		}
		
		private var _shadowMethod:ShadingMethodBase;
		
		
		public function ShadowMethodTrait(shadowMethod:ShadingMethodBase=null)
		{
			super();
			this.shadowMethod = shadowMethod;
		}
	}
}