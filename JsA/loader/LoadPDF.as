package JsA.loader
{
	import JsC.events.JEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.html.HTMLLoader;
	import flash.html.HTMLPDFCapability;
	import flash.net.URLRequest;
	
	//import mx.controls.Alert;

	[Event(name="COMPLETE", type="JsC.events.JEvent")]
	public class LoadPDF extends EventDispatcher
	{
		private var pdfLoader:HTMLLoader
		public function LoadPDF()
		{
			
		}
		
		public function load(_url:URLRequest):void
		{
			if(HTMLLoader.pdfCapability==HTMLPDFCapability.STATUS_OK)
			{
				pdfLoader = new HTMLLoader();        //HTML Control
				pdfLoader.addEventListener(Event.COMPLETE,onEvent)
				pdfLoader.addEventListener(Event.ADDED_TO_STAGE,onEvent)
				pdfLoader.cacheAsBitmap = true
				
				pdfLoader.load(_url);             //load pdf
			}else{
				//Alert.show("pdf cant display, not Adobe Reader 8.1 and above version");
			}
		}
		
		protected function onEvent(event:Event):void
		{
			switch(event.type)
			{
				case Event.ADDED_TO_STAGE:
					pdfLoader.width = pdfLoader.stage.stageWidth / 2;               //set pdf height
					pdfLoader.height = pdfLoader.stage.stageHeight -100; 
					break;
					
				case Event.COMPLETE:
					var _event:JEvent = new JEvent(JEvent.COMPLETE)
					_event.$setSprite(pdfLoader)
					dispatchEvent(_event)
					break
			}
			
		}		
	}
}