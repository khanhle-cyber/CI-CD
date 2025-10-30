import { LightningElement, api } from 'lwc';

export default class ColorToggleButton extends LightningElement {
    @api label = 'Đổi màu';
    @api colorOne = '#1e90ff'; // xanh
    @api colorTwo = '#ff4757'; // đỏ

    isFirst = true;

    get buttonStyle() {
        const bg = this.isFirst ? this.colorOne : this.colorTwo;
        const color = '#ffffff';
        // style binding in template is valid for LWC, returns inline CSS string
        return `background:${bg};color:${color};border:none;padding:0.6rem 1rem;border-radius:0.5rem;cursor:pointer;`;
    }

    handleClick() {
        this.isFirst = !this.isFirst;
    }
}
