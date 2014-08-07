package JsA.platform
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import JsC.mdel.SystemOS;

	public class AssignLoader
	{
		public function AssignLoader()
		{
			
			
		}
		
		public function setLoader(_loader:Loader,_url:String):void{
			
			if (SystemOS.isAndroid()){
				
				var file:File = new File(_url)
				if (file.exists)
				{
					var fs:FileStream = new FileStream
					
					fs.addEventListener(Event.COMPLETE,function(event:Event):void{
						fs.removeEventListener(event.type,arguments.callee);
						var bytes:ByteArray = new ByteArray();
						fs.readBytes(bytes)
						fs.addEventListener(Event.CLOSE,function(event:Event):void{
							_loader.loadBytes(bytes);
						});
						fs.readBytes(bytes)
						fs.close();
					})
					fs.openAsync(file,FileMode.READ);
				}else{
					_loader.load(new URLRequest(_url));
				}
			}else{
				_loader.load(new URLRequest(_url));
			}
		}
		
		public function setSoundLoader(_soundLoader:Sound,_url:String):void{
			
			if (SystemOS.isAndroid()){
				
				var file:File = new File(_url)
				if (file.exists)
				{
					_soundLoader.load(new URLRequest(file.url));
				}else{
					_soundLoader.load(new URLRequest(_url));
				}
				
			}else{
				_soundLoader.load(new URLRequest(_url));
			}
		}
	}
}