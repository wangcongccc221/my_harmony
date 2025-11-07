import { PopupAction } from '../PopupAction'

export interface ButtonOptions {
  text: string | Resource
  action?: (data?: PopupAction) => void
  fontColor?: ResourceColor
  fontSize?: Length
  backgroundColor?: ResourceColor,
  buttonType?: ButtonType
  border?: BorderOptions
}