package au.com.thefarmdigital.parallax.depthSorting
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	
	public class CameraDepthSorter implements IDepthSorter
	{
		public function depthSort(item1:IParallaxDisplay, item2:IParallaxDisplay):Number{
			var diff: Number = 0;
			if(item1.cameraDepth>item2.cameraDepth){
				diff = 1;
			}else if(item1.cameraDepth<item2.cameraDepth){
				diff = -1;
			}else{
				// everything after here is arbitrary (but consistant), this avoids flickering
				if(item1.position.x>item2.position.x){
					diff = 1;
				}else if(item1.position.x<item2.position.x){
					diff = -1;
				}else{
					if(item1.position.y>item2.position.y){
						diff = 1;
					}else if(item1.position.y<item2.position.y){
						diff = -1;
					}else{
						if (String(item1) > String(item2)) {
							diff = 1;
						} else if (String(item1) < String(item2)) {
							diff = -1;
						}
					}
				}
			}
			return diff;
		}
	}
}