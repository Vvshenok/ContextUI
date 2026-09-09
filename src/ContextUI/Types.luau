--!strict
--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
export type Target = GuiObject | BasePart | Model | Attachment
export type State = "Hidden" | "Following" | "Docked" | "Pinned" | "Destroyed"
export type ComponentKind = "Title" | "Description" | "Text" | "Image" | "Stat" | "Progress" | "Divider" | "Section" | "Keybind" | "Button" | "ButtonGroup" | "Custom"
export type Connection = { Disconnect: (self: Connection) -> () }
export type Signal<T> = {
	Connect: (self: Signal<T>, callback: (T) -> ()) -> Connection,
	Once: (self: Signal<T>, callback: (T) -> ()) -> Connection,
	Fire: (self: Signal<T>, value: T) -> (),
	Destroy: (self: Signal<T>) -> (),
}
export type AnimationConfig = {
	ShowDuration: number?, HideDuration: number?, ResizeDuration: number?,
	FollowSpeed: number?, ReducedMotion: boolean?,
}
export type ThemeName = "Default" | "Dark" | "Light" | "Glass" | "Midnight" | "Minimal" | "Terminal" | "Neon" | "Soft"
export type Theme = {
	Background: Color3, BackgroundTransparency: number, Text: Color3, SecondaryText: Color3,
	Accent: Color3, Button: Color3, ButtonHover: Color3, Stroke: Color3, StrokeTransparency: number,
	ButtonText: Color3, SectionText: Color3, ProgressTrack: Color3,
	ButtonCornerRadius: number, StrokeThickness: number,
	Font: Enum.Font, TitleFont: Enum.Font, TextSize: number, TitleSize: number,
	Padding: number, Gap: number, CornerRadius: number, ButtonPadding: number,
	ButtonHeight: number, ProgressHeight: number, IconSize: number, StatGap: number,
}
export type ThemeOverrides = {
	Background: Color3?, BackgroundTransparency: number?, Text: Color3?, SecondaryText: Color3?,
	Accent: Color3?, Button: Color3?, ButtonHover: Color3?, Stroke: Color3?, StrokeTransparency: number?,
	ButtonText: Color3?, SectionText: Color3?, ProgressTrack: Color3?,
	ButtonCornerRadius: number?, StrokeThickness: number?,
	Font: Enum.Font?, TitleFont: Enum.Font?, TextSize: number?, TitleSize: number?,
	Padding: number?, Gap: number?, CornerRadius: number?, ButtonPadding: number?,
	ButtonHeight: number?, ProgressHeight: number?, IconSize: number?, StatGap: number?,
}
export type Config = {
	MaxWidth: number?, MinWidth: number?, MaxHeight: number?, Offset: Vector2?, EdgePadding: number?,
	CloseDelay: number?, TransitionGrace: number?, SafePadding: number?, DockThreshold: number?,
	DisplayOrder: number?, WorldRayLength: number?, Interactive: boolean?, Theme: (ThemeName | ThemeOverrides)?, Animation: AnimationConfig?,
}
export type ResolvedAnimation = {
	ShowDuration: number, HideDuration: number, ResizeDuration: number,
	FollowSpeed: number, ReducedMotion: boolean,
}
export type ResolvedConfig = {
	MaxWidth: number, MinWidth: number, MaxHeight: number, Offset: Vector2, EdgePadding: number,
	CloseDelay: number, TransitionGrace: number, SafePadding: number, DockThreshold: number,
	DisplayOrder: number, WorldRayLength: number, Interactive: boolean?, Animation: ResolvedAnimation,
}
export type ComponentConfig = { Id: string?, ExpandedOnly: boolean? }
export type StatConfig = ComponentConfig & { Color: Color3? }
export type ButtonConfig = ComponentConfig & { Disabled: boolean?, KeyCode: Enum.KeyCode? }
export type CustomConfig = ComponentConfig & { Size: Vector2?, Interactive: boolean? }
export type ButtonSpec = { Text: string, Callback: (Context) -> (), Disabled: boolean?, KeyCode: Enum.KeyCode? }
export type Component = {
	Id: string, Kind: ComponentKind, Text: string, Value: string, Progress: number, Image: string,
	ExpandedOnly: boolean, Color: Color3?, Disabled: boolean, KeyCode: Enum.KeyCode?,
	Callback: ((Context) -> ())?, Buttons: {ButtonSpec}?, Gui: GuiObject?,
	CustomSize: Vector2?, Interactive: boolean,
}
export type Extension = { Name: string, Install: (Context) -> (() -> ())? }
export type Context = {
	StateChanged: Signal<State>, ExpandedChanged: Signal<boolean>,
	SetTitle: (self: Context, text: string) -> Context,
	SetDescription: (self: Context, text: string) -> Context,
	AddText: (self: Context, text: string, config: ComponentConfig?) -> Context,
	AddImage: (self: Context, image: string, config: ComponentConfig?) -> Context,
	SetIcon: (self: Context, image: string) -> Context,
	AddStat: (self: Context, label: string, value: string | number, config: StatConfig?) -> Context,
	SetStat: (self: Context, id: string, value: string | number) -> Context,
	AddProgress: (self: Context, label: string, value: number, config: ComponentConfig?) -> Context,
	SetProgress: (self: Context, id: string, value: number) -> Context,
	AddDivider: (self: Context, config: ComponentConfig?) -> Context,
	AddSection: (self: Context, text: string, config: ComponentConfig?) -> Context,
	AddKeybind: (self: Context, text: string, key: Enum.KeyCode, config: ComponentConfig?) -> Context,
	AddButton: (self: Context, text: string, callback: (Context) -> (), config: ButtonConfig?) -> Context,
	AddButtonGroup: (self: Context, buttons: {ButtonSpec}, config: ComponentConfig?) -> Context,
	AddCustom: (self: Context, gui: GuiObject, config: CustomConfig?) -> Context,
	SetText: (self: Context, id: string, text: string) -> Context,
	SetImage: (self: Context, id: string, image: string) -> Context,
	SetButtonEnabled: (self: Context, id: string, enabled: boolean) -> Context,
	Remove: (self: Context, id: string) -> Context,
	Clear: (self: Context) -> Context,
	SetExpandable: (self: Context, enabled: boolean, label: string?) -> Context,
	Expand: (self: Context) -> Context, Collapse: (self: Context) -> Context,
	ToggleExpanded: (self: Context) -> Context, IsExpanded: (self: Context) -> boolean,
	SetInteractive: (self: Context, interactive: boolean?) -> Context,
	IsInteractive: (self: Context) -> boolean,
	SetTheme: (self: Context, theme: ThemeName | ThemeOverrides, overrides: ThemeOverrides?) -> Context,
	SetTarget: (self: Context, target: Target?) -> Context,
	Bind: (self: Context) -> Context, Unbind: (self: Context) -> Context,
	Show: (self: Context, position: Vector2?) -> Context, Hide: (self: Context) -> Context,
	Pin: (self: Context) -> Context, Unpin: (self: Context) -> Context,
	GetState: (self: Context) -> State, GetSurface: (self: Context) -> CanvasGroup?,
	Use: (self: Context, extension: Extension) -> Context,
	Destroy: (self: Context) -> (),
}

return {}
